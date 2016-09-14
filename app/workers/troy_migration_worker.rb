class TroyMigrationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def create_object_activity record, pdns_domain
    unless record.type == "SOA"
      domain = Domain.find pdns_domain.domain_id

      ObjectActivity::Update.create activity_at: record.create_date,
                                    partner: domain.partner,
                                    product: domain.product,
                                    property_changed: "powerdns_record",
                                    value: record.name
    end
  end

  def create_new_ns_records record, pdns_domain, new_default_nameservers
    powerdns_record = Powerdns::Record.find_by_name_and_content(record.name, new_default_nameservers.first.name)

    if powerdns_record.nil?
      new_default_nameservers.each do |nameserver|
        powerdns_record = Powerdns::Record.new

        powerdns_record.powerdns_domain_id = pdns_domain.id
        powerdns_record.name               = record.name
        powerdns_record.type               = record.type
        powerdns_record.content            = nameserver.name
        powerdns_record.prio               = record.prio
        powerdns_record.ttl                = record.ttl
        powerdns_record.active             = record.active
        powerdns_record.start_date         = record.startdate
        powerdns_record.end_date           = record.expirydate
        powerdns_record.created_at         = record.create_date
        powerdns_record.updated_at         = record.modified_date
        powerdns_record.troy_migration     = true

        if powerdns_record.save
          powerdns_record.save
          create_object_activity record, pdns_domain
        else
          domain = Domain.find pdns_domain.domain_id
          error = "Partner #{domain.partner.name} for
            Domain #{domain.name} with ID - #{domain.id},
            got error while migrating reach_record with the following details --
            ID      - #{record.id}
            NAME    - #{record.name}
            TYPE    - #{record.type}
            CONTENT - #{record.content}
            Error message -- #{powerdns_record.errors.messages}
             "
          log ||= Logger.new("#{Rails.root}/log/troy_records_migrate_errors.log")
          log.info(error) unless error.nil?
        end
      end
    end
  end

  def create_dns_record record, pdns_domain, preferences
    powerdns_record = Powerdns::Record.find_by_name_and_content(record.name, record.content)

    if powerdns_record.nil?
      powerdns_record = Powerdns::Record.new

      powerdns_record.powerdns_domain_id = pdns_domain.id
      powerdns_record.name               = record.name
      powerdns_record.type               = record.type
      powerdns_record.content            = record.content
      powerdns_record.prio               = record.prio
      powerdns_record.ttl                = record.ttl
      powerdns_record.active             = record.active
      powerdns_record.start_date         = record.startdate
      powerdns_record.end_date           = record.expirydate
      powerdns_record.created_at         = record.create_date
      powerdns_record.updated_at         = record.modified_date
      powerdns_record.preferences        = preferences unless preferences.nil?
      powerdns_record.troy_migration     = true

      if powerdns_record.save
        powerdns_record.save
        create_object_activity record, pdns_domain
      else
        domain = Domain.find pdns_domain.domain_id
        error = "Partner #{domain.partner.name} for
          Domain #{domain.name} with ID - #{domain.id},
          got error while migrating reach_record with the following details --
          ID      - #{record.id}
          NAME    - #{record.name}
          TYPE    - #{record.type}
          CONTENT - #{record.content}
          Error message -- #{powerdns_record.errors.messages}
           "
        log ||= Logger.new("#{Rails.root}/log/troy_records_migrate_errors.log")
        log.info(error) unless error.nil?
      end
    end
  end

  def perform domain_id
    domain = Domain.find domain_id
    domain_name       = domain.name.split('.').first
    domain_array      = domain.name.split('.')
    domain_array.delete(domain_name)
    domain_ext        = ".#{domain_array.join('.')}"

    troy_domain = Troy::Domain.find_by_name_and_extension(domain_name, domain_ext)

    if troy_domain
      has_default_nameservers = true
      old_default_nameservers = ["nsfwd.domains.ph", "ns2.domains.ph"]
      new_default_nameservers = Nameserver.all
      troy_nameservers = troy_domain.nameservers

      pdns_domain = Powerdns::Domain.find_or_create_by(domain_id: domain.id) do |pdns_domain|
        pdns_domain.name = domain.name
      end

      if troy_nameservers
        unless troy_nameservers.count > 2
          troy_nameservers.each do |nameserver|
            if !old_default_nameservers.include? nameserver.downcase
              has_default_nameservers = false
            end
          end
        else
          has_default_nameservers = false
        end
      end

      if has_default_nameservers
        domain.product.domain_hosts.map{|nameserver| nameserver.delete}

        new_default_nameservers.each do |nameserver|
          domain.product.domain_hosts.create(
            product_id: domain.product_id,
            name: nameserver.name,
            created_at: troy_domain.createdate,
            updated_at: troy_domain.lastmodifieddate,
            troy_migration: true
          )

          ObjectActivity::Update.create activity_at: troy_domain.createdate,
                                        partner: domain.product.domain.partner,
                                        product: domain.product,
                                        property_changed: :domain_host,
                                        value: nameserver.name
        end
      else
        if troy_nameservers
          troy_nameservers.each do |nameserver|
            if !domain.product.domain_hosts.map{|ns| ns.name.downcase}.include? nameserver.downcase
              domain.product.domain_hosts.create(
                product_id: domain.product_id,
                name: nameserver,
                created_at: troy_domain.createdate,
                updated_at: troy_domain.lastmodifieddate,
                troy_migration: true
              )

              ObjectActivity::Update.create activity_at: troy_domain.createdate,
                                            partner: domain.product.domain.partner,
                                            product: domain.product,
                                            property_changed: :domain_host,
                                            value: nameserver
            end
          end
        end
      end

      troy_domain.reach_records.each do |record|
        if record.type == "SOA"
          if has_default_nameservers
            create_dns_record record, pdns_domain, nil
          end
        elsif record.type == "NS"
          if has_default_nameservers
            create_new_ns_records record, pdns_domain, new_default_nameservers
          else
            create_dns_record record, pdns_domain, nil
          end
        elsif record.type == "SRV"
          srv_values = record.content.split(' ')
          preferences = {:weight => "#{srv_values[0]}", :port => "#{srv_values[1]}", :srv_content => "#{srv_values[2].to_s}"}
          create_dns_record record, pdns_domain, preferences
        else
          create_dns_record record, pdns_domain, nil
        end
      end
    end
  end
end
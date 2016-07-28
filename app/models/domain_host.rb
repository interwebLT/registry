class DomainHost < ActiveRecord::Base
  belongs_to :product

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:name, :product] }

#  validate :name_must_match_existing_host

  after_create :create_add_domain_host_domain_activity
  after_create :create_pdns_domain_and_record_and_update_end_date
  before_destroy :create_remove_domain_host_domain_activity
  after_destroy :update_domain_status
  after_destroy :update_powerdns_record_end_dates

  skip_callback :create, :after, :create_add_domain_host_domain_activity, if: :troy_migration

  attr_accessor :troy_migration

  private

  def name_must_match_existing_host
    return unless errors[:name].empty?

    errors.add :name, I18n.t('errors.messages.invalid') unless Host.exists?(name: self.name)
  end

  def create_add_domain_host_domain_activity
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.product.domain.partner,
                                  product: self.product,
                                  property_changed: :domain_host,
                                  value: self.name

    product.domain.update_status
  end

  def create_remove_domain_host_domain_activity
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.product.domain.partner,
                                  product: self.product,
                                  property_changed: :domain_host,
                                  old_value: self.name
  end

  def update_domain_status
    product.domain.save
  end

  def create_pdns_domain_and_record_and_update_end_date
    output = true
    domain = Domain.find_by_product_id self.product_id
    nameservers = Nameserver.all
    hosts = domain.product.domain_hosts
    date_today = Date.today.strftime("%Y%m%d")

    if hosts.count != nameservers.count
      output = false
    else
      hosts.each do |host|
        output = nameservers.map{|nameserver| nameserver.name}.include?(host.name.strip)
        break if !output
      end
    end

    if output
      powerdns_domain =  Powerdns::Domain.find_or_create_by(domain_id: domain.id) do |pdns_domain|
        pdns_domain.name = domain.name
      end

      Powerdns::Record.find_or_create_by(powerdns_domain_id: powerdns_domain.id) do |powerdns_record|
        powerdns_record.name = powerdns_domain.name
        powerdns_record.type = "SOA"
        powerdns_record.prio = 0
        powerdns_record.content = "nsfwd.domains.ph root.nsfwd.domains.ph #{date_today}01 28800 7200 864000 14400"
        powerdns_record.end_date = domain.expires_at
      end

      nameservers.each do |nameserver|
        Powerdns::Record.create(
          powerdns_domain_id: powerdns_domain.id,
          name: powerdns_domain.name,
          type: "NS",
          content: nameserver.name,
          end_date: domain.expires_at
        )
      end
    else
      powerdns_domain = Powerdns::Domain.find_by_domain_id(domain.id)

      if powerdns_domain
        powerdns_records = powerdns_domain.powerdns_records

        if powerdns_records
          powerdns_records.each do |powerdns_record|
            powerdns_record.end_date = DateTime.now + 1.day
            powerdns_record.save!
          end
        end
      end
    end
  end

  def update_powerdns_record_end_dates
    output = true
    domain = Domain.find_by_product_id self.product_id
    nameservers = Nameserver.all
    hosts = domain.product.domain_hosts

    if hosts.count != nameservers.count
      output = false
    else
      hosts.each do |host|
        output = nameservers.map{|nameserver| nameserver.name}.include?(host.name.strip)
        break if !output
      end
    end

    if output
      powerdns_domain = Powerdns::Domain.find_by_domain_id(domain.id)

      if powerdns_domain
        powerdns_records = powerdns_domain.powerdns_records

        if powerdns_records
          powerdns_records.each do |powerdns_record|
            powerdns_record.end_date = domain.expires_at
            powerdns_record.save!
          end
        end
      end
    end
  end
end

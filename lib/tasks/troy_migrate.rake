namespace :db do
  desc "Migrate powerdns records from troy for each partner"
  task migrate_dns_records: :environment do
    @partners = Partner.all
    @partners.each do |partner|
      partner.migrate_domain_dns
      sleep 0.10
    end
  end

  desc "Migrate Partner Credits from view tables"
  task migrate_partner_credits: :environment do
    partners = Partner.all

    partners.each do |partner|
      partner.migrate_credits
    end
    puts "Partner credit sync done."
  end

  desc "Migrate Partner epp_partner boolean form SinagPartners"
  task update_partner_epp_partner_field: :environment do
    sinag_partners = SinagPartner.all.pluck(:name)
    partners = Partner.all

    partners.each do |partner|
      if sinag_partners.include?(partner.name)
        partner.epp_partner = true
        partner.save!
        puts "Partner #{partner.name} epp_partner field updated."
      end
    end
  end

  desc "create initial large credit limit per partner"
  task assign_partner_initial_credit_limit: :environment do
    partners = Partner.all
    partners.each do |partner|
      partner.partner_configurations.create!(
        config_name: 'credit_limit',
        value: '999999999'
      )
      puts "$999,999,999 credit limit was assigned to #{partner.name}"
    end
  end

  desc "Fix Host Ownership"
  task reset_host_partner: :environment do
    hosts = Host.all

    hosts.map{|host|
      if host.top_level_domain == "ph"
        domain  = Domain.find_by_name host.get_root_domain

        unless domain.nil?
          if domain.partner != host.partner
            host.partner = domain.partner
            if host.save
              host.host_addresses.delete_all
              puts "#{host.name} partner updated"
            end
          end
        end
      end
    }
    puts "Host ownership cleanup done."
  end

  desc "Delete all unused host"
  task delete_orphan_hosts: :environment do
    hosts = Host.all

    hosts.each do |host|
      if !DomainHost.exists?(name: host.name)
        host.destroy!
        puts "#{host.name} destroyed."
      end
    end
    puts "Deletion of unused Hosts done."
  end

  desc "Re-Sync all existing Hosts to Cocca"
  task sync_all_hosts_to_cocca: :environment do
    hosts = Host.all

    hosts.each do |host|
      unless ["comlaude", "domrobot", "test-ipmirror", "test-unitedag"].include?(host.partner.name)
        if DomainHost.exists?(name: host.name)
          if host.top_level_domain == "ph"
            host_domain = host.get_root_domain
            unless Domain.find_by_name(host_domain).nil?
              remigrate_host host
            end
          else
            remigrate_host host
          end
        end
      end
      sleep 0.10
    end
    puts "Host re-sync to cocca done."
  end

  desc "Update sinag and cocca domain expiration date"
  task update_sinag_domain_expiration_date_from_troy: :environment do
    mismatch_domains = Troy::MismatchDomainExpireDate.all

    mismatch_domains.each do |mismatch_domain|
      troy_expire_date = mismatch_domain.troy_expires_at

      sinag_domain = Domain.find_by_name(mismatch_domain.domain)
      if !sinag_domain.nil?
        sinag_domain.expires_at = troy_expire_date
        sinag_domain.save!
        puts "Domain #{sinag_domain.name} expiration date in sinag was updated."
      end

      cocca_domain = Cocca::Domain.find_by_name(mismatch_domain.domain)

      if !cocca_domain.nil?
        cocca_domain.exdate = troy_expire_date
        cocca_domain.save!
        puts "Domain #{cocca_domain.name} expiration date in cocca was updated."
      end
    end
    puts "Domain Expiration Date update done. Please check your data."
  end

  desc "Update cocca domain expiration from troy partners"
  task update_cocca_domain_expiration_of_troy_partners: :environment do
    mismatch_domains = Cocca::MismatchSinagDomainExdateTroyPartner.all

    mismatch_domains.each do |mismatch_domain|
      cocca_domain = Cocca::Domain.find_by_name(mismatch_domain.domain)

      if !cocca_domain.nil?
        cocca_domain.exdate = mismatch_domain.sinag_expires_at
        cocca_domain.save!
        puts "Domain #{cocca_domain.name} expiration date in cocca was updated."
      end
    end
    puts "Domain Expiration Date update done. Please check your data."
  end

  desc "Update sinag domain expiration from epp partners"
  task update_sinag_domain_expiration_date_of_epp_partners: :environment do
    mismatch_domains = Cocca::MismatchSinagDomainExdateEppPartner.all
    exclude_domain = ["udic-1-1441877987-a71itz3mn0c4uquzrqwwp9iptkjbaqdw0tkeknzquhrwo.ph", "udic-1-1449070216-gn9s3zlvoajn2gyrjwtbanbi57ma99vc53zr5jdkd2xke.ph"]
    mismatch_domains.each do |mismatch_domain|
      if !mismatch_domain.partner.nil? and !mismatch_domain.domain.nil?
        domain = Domain.find_by_name(mismatch_domain.domain)

        if !domain.nil? and !exclude_domain.include?(domain.name)
          domain.expires_at = mismatch_domain.cocca_expires_at
          domain.save!
          puts "Domain #{domain.name} expiration date in sinag was updated."
        end
      end
    end
    puts "Domain Expiration Date update done. Please check your data."
  end

  desc "update domain host from sinag to cocca"
  task update_cocca_domain_host: :environment do
    mismatch_domain_hosts = Cocca::MismatchDomainHost.all
    sinag_partners = SinagPartner.all.pluck(:name)
    url = ExternalRegistry.find_by_name("cocca").url

    mismatch_domain_hosts.each do |mismatch_domain_host|
      if !mismatch_domain_host.partner.nil? and !sinag_partners.include?(mismatch_domain_host.partner)
        domain = Domain.find_by_name(mismatch_domain_host.domain)
        domain_url = "#{url}/domains/#{domain.name}"
        header   = {"Content-Type"=>"application/json", "Accept"=>"application/json", "Authorization"=>"Token token=#{domain.partner.name}"}
        headers  = {headers: header}

        domain_still_available_in_cocca = process_response HTTParty.get(domain_url, headers)

        if domain_still_available_in_cocca
          if !mismatch_domain_host.cocca.nil?
            cocca_domain_host_for_delete = mismatch_domain_host.cocca.split(",")
            cocca_domain_host_for_create = mismatch_domain_host.sinag.split(",")
            SyncCreateDeleteBulkDomainHostJob.perform_later url, domain, cocca_domain_host_for_delete, cocca_domain_host_for_create
          else
            sinag_domain_hosts = mismatch_domain_host.sinag.split(",")

            sinag_domain_hosts.each do |sinag_domain_host|
              domain_host = domain.product.domain_hosts.where(name: sinag_domain_host).first
              if !domain_host.nil?
                SyncCreateDomainHostJob.perform_later url, domain_host
              end
            end
          end
          puts "Domain #{mismatch_domain_host.domain} domain_hosts in cocca was updated."
        end
      end
      sleep 0.10
    end
  end

  desc "Update IP list field in sinag"
  task update_domain_host_ip_list_field: :environment do
    domain_hosts    = DomainHost.all
    default_ip_list = {"ipv4":{"0": ""},"ipv6":{"0": ""}}.to_json

    domain_hosts.each do |domain_host|
      if domain_host.name.split(".").last == "ph"
        if domain_host.glue_record?
          host = Host.find_by_name(domain_host.name)
          if !host.nil?
            host_addresses = host.host_addresses
            if !host_addresses.blank?
              host_addresses.each do |host_address|
                host_address.save
                puts "Domain Host IP List field for #{domain_host.name} was updated."
              end
            end
          end
        end
        puts "#{domain_host.name}"
      end
    end
  end

  desc "resync host address from troy"
  task sync_all_host_address_to_sinag: :environment do
    troy_domains = Troy::Domain.troy_partner_domains.select(:name, :extension, :ns1, :ns2, :ns3, :ns1ip, :ns2ip, :ns3ip, :ns1ipv6, :ns2ipv6, :ns3ipv6)

    troy_domains.each do |troy_domain|
      if !troy_domain.with_default_nameservers?
        if troy_domain.glue_record_nameserver?(troy_domain.ns_1)
          remigrate_host_address troy_domain.ns_1, troy_domain.ns_1_ip, troy_domain.ns_1_ipv6
        end
        if troy_domain.glue_record_nameserver?(troy_domain.ns_2)
          remigrate_host_address troy_domain.ns_2, troy_domain.ns_2_ip, troy_domain.ns_2_ipv6
        end
        if troy_domain.glue_record_nameserver?(troy_domain.ns_3)
          remigrate_host_address troy_domain.ns_3, troy_domain.ns_3_ip, troy_domain.ns_3_ipv6
        end
      end
    end
    puts "Troy Host Address Re-Sync done."
  end

  def remigrate_host_address hostname, ipv4, ipv6
    host = Host.find_by_name(hostname)
    if !host.nil?
      ipv4_host_address = host.host_addresses.where(type: "v4")
      if !ipv4.blank?
        if ipv4_host_address.blank?
          host.host_addresses.create(address: ipv4, type: "v4")
          puts "Host Address of #{hostname} was resync to Sinag."
        else
          if host.host_addresses.where(type: "v4").count > 1
            host.host_addresses.where(type: "v4").delete_all
            host.host_addresses.create(address: ipv4, type: "v4")
            puts "Host Address of #{hostname} was resync to Sinag."
          else
            if !host.host_addresses.where(type: "v4").first.address == ipv4
              host.host_addresses.where(type: "v4").delete_all
              host.host_addresses.create(address: ipv4, type: "v4")
              puts "Host Address of #{hostname} was resync to Sinag."
            else
              puts "Host Address of #{hostname} in Troy already matches in Sinag."
            end
          end
        end
      end

      ipv6_host_address = host.host_addresses.where(type: "v6")
      if !ipv6.blank?
        if ipv6_host_address.blank?
          host.host_addresses.create(address: ipv6, type: "v6")
          puts "Host Address of #{hostname} was resync to Sinag."
        else
          if host.host_addresses.where(type: "v6").count > 1
            host.host_addresses.where(type: "v6").delete_all
            host.host_addresses.create(address: ipv6, type: "v6")
            puts "Host Address of #{hostname} was resync to Sinag."
          else
            if !host.host_addresses.where(type: "v6").first.address == ipv6
              host.host_addresses.where(type: "v6").delete_all
              host.host_addresses.create(address: ipv6, type: "v6")
              puts "Host Address of #{hostname} was resync to Sinag."
            else
              puts "Host Address of #{hostname} in Troy already matches in Sinag."
            end
          end
        end
      end
    end
  end

  def remigrate_host host
    url   = ExternalRegistry.find_by_name("cocca").url
    host_url = "#{url}/hosts/#{host.name}"
    header   = {"Content-Type"=>"application/json", "Accept"=>"application/json", "Authorization"=>"Token token=#{host.partner.name}"}
    headers  = {headers: header}

    host_already_in_cocca = process_response HTTParty.get(host_url, headers)

    if host_already_in_cocca
      puts "#{host.name} already exist in cocca."
    else
      SyncCreateHostJob.perform_later url, host
      puts "#{host.name} re-sync to cocca started."
    end
  end

  def process_response response
    if (400..599).include? response.code
      false
    else
      true
    end
  end
end

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
      sleep 0.10
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

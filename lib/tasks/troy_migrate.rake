namespace :db do
  desc "Migrate records from troy"
  task troy_migrate: :environment do
    %w(db:migrate_dns_records).each do |t|
      Rake::Task[t].invoke
      puts "Migration on backround process. Please refer to troy_records_migrate_errors.log to check errors if any."
    end
  end

  desc "Migrate powerdns records from troy for each partner"
  task migrate_dns_records: :environment do
    @partners = Partner.all

    @partners.each do |partner|
      puts partner.name
      partner.domains.each do |domain|
        domain.migrate_records
      end
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
  end

  desc "Re-Sync all existing Hosts to Cocca"
  task sync_all_hosts_to_cocca: :environment do
    hosts = Host.all
    url   = ExternalRegistry.find_by_name("cocca").url

    hosts.each do |host|
      url      = ExternalRegistry.find_by_name("cocca").url
      host_url = "#{url}/hosts/#{host.name}"
      header   = {"Content-Type"=>"application/json", "Accept"=>"application/json", "Authorization"=>"Token token=host.partner.name"}
      headers  = {headers: header}

      host_already_in_cocca = process_response HTTParty.get(host_url, headers)

      if host_already_in_cocca
        puts "#{host.name} already exist in cocca."
      else
        SyncCreateHostJob.perform_later url, host
        puts "#{host.name} re-sync to cocca started."
      end
      sleep 0.20
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

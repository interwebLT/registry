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
  task clean_up_host_table: :environment do
    hosts = Host.all

    hosts.map{|host|
      if host.top_level_domain == "ph"
        host_array = host.name.split(".")
        if host.has_valid_second_level_domain
          has_two_valid_extensions = true
        end

        if has_two_valid_extensions
          domain_name = host_array[host_array.length - 3] + "." + host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
        else
          domain_name = host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
        end
        domain  = Domain.find_by_name domain_name

        unless domain.nil?
          if domain.partner != host.partner
            host.partner = domain.partner
            if host.save
              host.host_addresses.delete_all
            end
          end
        end
      end
    }
  end
end

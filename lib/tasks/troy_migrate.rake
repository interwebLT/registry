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
end

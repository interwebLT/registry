class AddPowerdnsDomainForExistingEnvironments < ActiveRecord::Migration
  def change
    Domain.all.each do |domain|
      Powerdns::Domain.find_or_create_by(domain_id: domain.id) do |pdns_domain|
        pdns_domain.name = domain.name
        puts "Powerdns::Domain record for #{domain.name} generated!"
      end
    end
  end
end
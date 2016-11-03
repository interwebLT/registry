# every 1.days do
#   runner "ExpireDomainsJob.perform_now"
# end

# every '0 10 20 * *' do
#   rake "db:generate_partner_invoice_statement" , environment: "development"
# end

## COMMENT FOR NOW##
# every :day, at: '8am', roles: [:app] do
#   rake "db:generate_partner_renewal_notices" , environment: "development"
# end

## Re sync expiration domains
every :day, at: '7am', roles: [:app] do
  rake "db:update_sinag_domain_expiration_date_from_troy"
  rake "db:update_cocca_domain_expiration_of_troy_partners"
  rake "db:update_sinag_domain_expiration_date_of_epp_partners"
end

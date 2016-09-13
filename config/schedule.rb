# every 1.days do
#   runner "ExpireDomainsJob.perform_now"
# end

# every 1.minute do
#   rake "db:generate_partner_billing_statement" , environment: "development"
# end

# every 1.day, at: "9:00 am" do
#   rake "db:generate_partner_renewal_notices" , environment: "development"
# end

## COMMENT FOR NOW##
# every :day, at: '8am', roles: [:app] do
#   rake "db:generate_partner_renewal_notices" , environment: "development"
# end
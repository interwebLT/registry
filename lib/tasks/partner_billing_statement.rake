namespace :db do
  desc "Generate Billing statement for partner"
  task generate_partner_billing_statement: :environment do
    # @partners = Partner.all
    partner = Partner.find(4)
    credits = partner.credits
    orders  = partner.orders
    PartnerBillingMailer.delay_for(5.second, queue: "registry_mailer").billing_statement(partner, credits, orders)
    puts "Billing statment generated."
    ##TODO##
  end
end

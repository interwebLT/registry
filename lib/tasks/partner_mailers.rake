namespace :db do
  desc "Generate Billing statement for partner"
  task generate_partner_invoice_statement: :environment do
    from = Date.today - 1.month
    to   = Date.today
    # @partners = Partner.all
    partner = Partner.last
    credits = partner.credits.where("credited_at > ? and credited_at <= ?", from, to)
    orders  = partner.orders.where("completed_at > ? and completed_at <= ?", from, to)
    PartnerInvoiceMailer.delay_for(5.second, queue: "registry_mailer").invoice_letter(partner, credits, orders)
    ##TODO##
    puts "done"
  end

  desc "Generate Domain Renewal Notices for partner"
  task generate_partner_renewal_notices: :environment do
    partners = Partner.includes(:domains)

    partners.each do |partner|
      domains = partner.domains.where("expires_at < ?", Date.today + 91.days)

      [90, 30, 15, 0].map{|num|
        domain_array = []
        deleted_domain_array = []
        domains.each do |domain|
          if domain.expires_at.to_date >= Date.today
            if (domain.expires_at - num.days).to_date == Date.today
              domain_array << domain
            end
          else
            deleted_domain_array << domain
          end
        end
        unless domain_array.empty?
          PartnerRenewalNoticeMailer.delay_for(5.second, queue: "registry_mailer").send_renewal_notice(partner, domain_array, num)
        end
        unless deleted_domain_array.empty?
          PartnerRenewalNoticeMailer.delay_for(5.second, queue: "registry_mailer").send_deleted_notice(partner, deleted_domain_array)
        end
      }
    end
    puts "done"
  end
end


class UpdateDomainTransferPartnerPricing < ActiveRecord::Migration
  def change
    Partner.all.each do |partner|
      partner.partner_pricings.where(action: 'domain_transfer').each do |transfer_pricing|
        transfer_pricing.action = 'transfer_domain'
        transfer_pricing.save!
      end
    end
  end
end

class PartnerPricing < ActiveRecord::Base
  self.table_name = 'partner_pricing'

  monetize :price_cents

  belongs_to :partner

  def self.sorted_by_transfer_register_renew
    PartnerPricing.all.sort_by(&:sort_action)
  end

  def sort_action
    if self.action == "transfer_domain"
      position = 1
    elsif self.action == "domain_create"
      position = 2
    elsif self.action == "domain_renew"
      position = 3
    else
    end
    return position
  end
end

class PartnerPricing < ActiveRecord::Base
  self.table_name = 'partner_pricing'

  monetize :price_cents

  belongs_to :partner
end

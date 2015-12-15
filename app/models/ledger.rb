class Ledger < ActiveRecord::Base
  self.table_name = 'ledger'

  belongs_to :partner
  belongs_to :credit
  belongs_to :order

  monetize :amount_cents
end

class Credit < ActiveRecord::Base
  self.table_name = 'ledger'

  belongs_to :partner
  belongs_to :order
end

class Troy::EcnTransaction < ActiveRecord::Base
  self.table_name = 'troy_ecn_transaction'
  self.primary_key = 'id'
end
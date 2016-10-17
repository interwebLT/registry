class Cocca::Domain < ActiveRecord::Base
  establish_connection :public_cocca_db
  self.table_name = 'domain'
end
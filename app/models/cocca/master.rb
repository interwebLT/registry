class Cocca::Master < ActiveRecord::Base
  establish_connection :audit_cocca_db
  self.table_name = 'audit.master'
end

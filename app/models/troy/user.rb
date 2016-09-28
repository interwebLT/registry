class Troy::User < ActiveRecord::Base
  self.table_name = 'troy_users'
  self.inheritance_column = :_type_disabled
end
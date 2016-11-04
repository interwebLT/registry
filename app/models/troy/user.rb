class Troy::User < ActiveRecord::Base
  self.table_name = 'troy_users'
  self.inheritance_column = :_type_disabled

  scope :partners, -> {where("trim(type) = ? and userid not like ? and userid not like ?", "partner", "cp%", "tp%")}
end

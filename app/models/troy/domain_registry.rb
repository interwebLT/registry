class Troy::DomainRegistry < ActiveRecord::Base
  self.table_name = 'troy_domains'
  self.primary_key = 'id'
end
class DomainActivity < ActiveRecord::Base
  self.table_name = 'domain_activity'

  belongs_to :partner
  belongs_to :domain
end

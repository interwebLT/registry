class Troy::MismatchDomainExpireDate < ActiveRecord::Base
  self.table_name  = 'check_troy_sinag_domain_expirydate'
  self.primary_key = 'id'
end
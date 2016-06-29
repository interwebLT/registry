class Powerdns::Record < ActiveRecord::Base
  belongs_to :powerdns_domain, class_name: Powerdns::Domain
  self.inheritance_column = :_type_disabled
end

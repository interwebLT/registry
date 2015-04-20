class DeletedDomain < ActiveRecord::Base
  belongs_to :product
  belongs_to :partner

  belongs_to :registrant,       class_name: Contact,  foreign_key: :registrant_handle
  belongs_to :admin_contact,    class_name: Contact,  foreign_key: :admin_handle
  belongs_to :billing_contact,  class_name: Contact,  foreign_key: :billing_handle
  belongs_to :tech_contact,     class_name: Contact,  foreign_key: :tech_handle
end

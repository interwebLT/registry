class DeletedDomain < ActiveRecord::Base
  belongs_to :product
  belongs_to :partner

  belongs_to :registrant,       class_name: Contact,  foreign_key: :registrant_handle
  belongs_to :admin_contact,    class_name: Contact,  foreign_key: :admin_handle
  belongs_to :billing_contact,  class_name: Contact,  foreign_key: :billing_handle
  belongs_to :tech_contact,     class_name: Contact,  foreign_key: :tech_handle

  def restore!
    Domain.create product:                    self.product,
                  partner:                    self.partner,
                  name:                       self.name,
                  authcode:                   self.authcode,
                  registrant_handle:          self.registrant_handle,
                  admin_handle:               self.admin_handle,
                  billing_handle:             self.billing_handle,
                  tech_handle:                self.tech_handle,
                  registered_at:              self.registered_at,
                  expires_at:                 self.expires_at,
                  ok:                         self.ok,
                  inactive:                   self.inactive,
                  client_renew_prohibited:    self.client_renew_prohibited,
                  client_delete_prohibited:   self.client_delete_prohibited,
                  client_transfer_prohibited: self.client_transfer_prohibited,
                  client_update_prohibited:   self.client_update_prohibited

    self.delete
  end
end

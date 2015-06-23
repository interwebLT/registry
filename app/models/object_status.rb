# This class should no longer be actively used. However, it's required so that
# the migrations still work properly.
class ObjectStatus < ActiveRecord::Base
  belongs_to :product

  def update_status
    enforce_status
  end

  private

  def enforce_status
    prohibited = client_delete_prohibited
    prohibited = (prohibited or client_renew_prohibited)
    prohibited = (prohibited or client_transfer_prohibited)
    prohibited = (prohibited or client_update_prohibited)

    self.inactive = self.product.domain_hosts.empty?

    self.ok = (not (inactive or client_hold or prohibited))

    true
  end

  def create_object_activity
    return true unless self.product.domain
    
    create_update_activity :ok                          if ok_changed?
    create_update_activity :inactive                    if inactive_changed?
    create_update_activity :client_hold                 if client_hold_changed?
    create_update_activity :client_delete_prohibited    if client_delete_prohibited_changed?
    create_update_activity :client_renew_prohibited     if client_renew_prohibited_changed?
    create_update_activity :client_transfer_prohibited  if client_transfer_prohibited_changed?
    create_update_activity :client_update_prohibited    if client_update_prohibited_changed?
  end

  def create_update_activity status
    ObjectActivity::Update.create activity_at: Time.now,
                                  partner: self.product.domain.partner,
                                  product: self.product,
                                  property_changed: status.to_s,
                                  old_value: self.send(status.to_s + '_was').to_s,
                                  value: self.send(status.to_s).to_s
  end
end

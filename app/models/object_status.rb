class ObjectStatus < ActiveRecord::Base
  belongs_to :product

  has_many :object_status_histories

  before_save :enforce_status
  before_save :create_object_activity

  after_save  :create_object_status_history

  def update_status
    enforce_status
    self.save
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

  def create_object_status_history
    ObjectStatusHistory.create  object_status:              self,
                                ok:                         self.ok,
                                inactive:                   self.inactive,
                                client_hold:                self.client_hold,
                                client_delete_prohibited:   self.client_delete_prohibited,
                                client_renew_prohibited:    self.client_renew_prohibited,
                                client_transfer_prohibited: self.client_transfer_prohibited,
                                client_update_prohibited:   self.client_update_prohibited
  end
end

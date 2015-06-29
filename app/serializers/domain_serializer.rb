class DomainSerializer < ActiveModel::Serializer
  attributes  :id, :zone, :name, :partner, :registered_at, :expires_at,
              :registrant, :registrant_handle, :admin_handle, :billing_handle, :tech_handle,
              :client_hold, :client_delete_prohibited, :client_renew_prohibited,
              :client_transfer_prohibited, :client_update_prohibited,
              :expired?, :expiring?

  def name
    object.full_name
  end

  def partner
    object.partner.name
  end

  def registrant
    ContactSerializer.new(object.registrant).serializable_hash
  end

  def registered_at
    object.registered_at.iso8601
  end

  def expires_at
    object.expires_at.iso8601
  end

  def client_hold
    object_status.client_hold
  end

  def client_delete_prohibited
    object_status.client_delete_prohibited
  end

  def client_renew_prohibited
    object_status.client_renew_prohibited
  end

  def client_transfer_prohibited
    object_status.client_transfer_prohibited
  end

  def client_update_prohibited
    object_status.client_update_prohibited
  end

  private

  def object_status
    object
  end
end

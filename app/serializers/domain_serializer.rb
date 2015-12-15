class DomainSerializer < ActiveModel::Serializer
  attributes  :id, :zone, :name, :partner, :registered_at, :expires_at,
              :registrant_handle, :admin_handle, :billing_handle, :tech_handle,
              :client_hold, :client_delete_prohibited, :client_renew_prohibited,
              :client_transfer_prohibited, :client_update_prohibited,
              :expired?, :expiring?

  def name
    object.full_name
  end

  def partner
    object.partner.name if object.partner
  end

  def registered_at
    object.registered_at.iso8601
  end

  def expires_at
    object.expires_at.iso8601
  end
end

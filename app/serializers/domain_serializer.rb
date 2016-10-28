class DomainSerializer < ActiveModel::Serializer
  attributes  :id, :zone, :name, :partner, :registered_at, :expires_at,
              :registrant_handle, :admin_handle, :billing_handle, :tech_handle, :inactive,
              :client_hold, :client_delete_prohibited, :client_renew_prohibited,
              :client_transfer_prohibited, :client_update_prohibited,
              :server_hold, :server_delete_prohibited, :server_renew_prohibited,
              :server_transfer_prohibited, :server_update_prohibited,
              :status_pending_transfer, :ok,
              :expired?, :expiring?

  def name
    object.full_name
  end

  def partner
    object.partner.name
  end

  def registered_at
    object.registered_at.iso8601
  end

  def expires_at
    object.expires_at.iso8601
  end
end

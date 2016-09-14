class SyncCreateBulkHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host, ip_array
    host_url          = "#{url}/hosts/#{host.name}"
    host_address_url  = "#{host_url}/addresses"

    body = {
      address:  "",
      type:     "",
      ip_list:  ip_array
    }

    post host_address_url, body, token: host.partner.name
  end
end
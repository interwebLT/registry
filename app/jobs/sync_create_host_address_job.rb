class SyncCreateHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host_address
    host = host_address.host

    host_address_url = "#{url}/hosts/#{host.name}/addresses"

    body = {
      address:  host_address.address,
      type:     host_address.type
    }

    post host_address_url, body, token: host.partner.name
  end
end

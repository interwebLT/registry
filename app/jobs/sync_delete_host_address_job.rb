class SyncDeleteHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, address, host, retry_count = 0
    host_url          = "#{url}/hosts/#{host.name}"
    host_address_url  = "#{host_url}/addresses/#{address}"

    delete host_address_url, token: host.partner.name
  end
end

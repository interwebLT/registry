class SyncCreateHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host_address, retry_count = 0
    host = host_address.host

    host_url          = "#{url}/hosts/#{host.name}"
    host_address_url  = "#{host_url}/addresses"

    raise 'Max retry reached!' unless retry_count < MAX_SYNC_RETRY_COUNT

    unless check host_url, token: host.partner.name
      SyncCreateHostAddressJob.perform_later url, host_address, (retry_count + 1)

      return
    end

    body = {
      address:  host_address.address,
      type:     host_address.type
    }

    post host_address_url, body, token: host.partner.name
  end
end

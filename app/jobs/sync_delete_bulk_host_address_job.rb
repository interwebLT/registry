class SyncDeleteBulkHostAddressJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host, ip_array
    host_url          = "#{url}/hosts/#{host.name}"
    host_address_url  = "#{host_url}/addresses/#{ip_array.first}?ip_list=#{ip_array.join(",")}"

    delete host_address_url, token: host.partner.name
  end
end

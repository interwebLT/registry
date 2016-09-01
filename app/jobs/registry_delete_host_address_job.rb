class RegistryDeleteHostAddressJob < ApplicationJob
  queue_as :internal_registry_changes

  def perform url, host_address, token
    host = host_address.host

    host_url          = "#{url}/hosts/#{host.name}"
    host_address_url  = "#{host_url}/addresses/#{host_address.address}?internal_sync=true"

    delete host_address_url, token: token
  end
end

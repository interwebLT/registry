class RegistryCreateHostAddressJob < ApplicationJob
  queue_as :internal_registry_changes

  def perform url, params, token
    host_url          = "#{url}/hosts/#{params[:hostname]}"
    host_address_url  = "#{host_url}/addresses"

    body = {
      address:  params[:address],
      type:     params[:type]
    }

    post host_address_url, body, token: token
  end
end

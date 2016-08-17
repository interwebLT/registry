class RegistryCreateHostJob < ApplicationJob
  queue_as :internal_registry_changes

  def perform url, host, token
    ip_list = host[:ip_list]
    body = {
      name: host[:name]
    }

    post "#{url}/hosts", body, token: token

    unless ip_list["ipv4"]["0"].empty? && ip_list["ipv6"]["0"].empty?
      host_url          = "#{url}/hosts/#{host[:name]}"
      host_address_url  = "#{host_url}/addresses"

      unless ip_list["ipv4"]["0"].empty?
        ip_list["ipv4"].map{|key,value|
          body = {
            address:  value,
            type:     "v4"
          }
          post host_address_url, body, token: token
        }
      end

      unless ip_list["ipv6"]["0"].empty?
        ip_list["ipv6"].map{|key,value|
          body = {
            address:  value,
            type:     "v6"
          }
          post host_address_url, body, token: token
        }
      end
    end
  end
end

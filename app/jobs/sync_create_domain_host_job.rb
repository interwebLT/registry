class SyncCreateDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, domain, domain_host
    domain_host_url = "#{url}/domains/#{domain}/hosts"

    params = {
      name: domain_host
    }

    post url: domain_host_url, params: params, token: partner.name
  end
end

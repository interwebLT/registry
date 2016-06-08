class SyncCreateDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, domain_host
    domain = domain_host.product.domain

    domain_host_url = "#{url}/domains/#{domain.name}/hosts"

    body = {
      name: domain_host.name
    }

    post domain_host_url, body, token: domain.partner.name
  end
end

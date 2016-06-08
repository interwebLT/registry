class SyncDeleteDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, domain_host
    domain = domain_host.product.domain

    delete "#{url}/domains/#{domain.name}/hosts/#{domain_host.name}", token: domain.partner.name
  end
end

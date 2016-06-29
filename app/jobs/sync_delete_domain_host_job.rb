class SyncDeleteDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, domain_host, retry_count = 0
    domain = domain_host.product.domain

    domain_url      = "#{url}/domains/#{domain.name}"
    domain_host_url = "#{domain_url}/hosts/#{domain_host.name}"

    raise 'Max retry reached!' unless retry_count < MAX_SYNC_RETRY_COUNT

    unless check domain_url, token: domain.partner.name
      SyncDeleteDomainHostJob.perform_later url, domain_host, (retry_count + 1)

      return
    end

    delete domain_host_url, token: domain.partner.name
  end
end

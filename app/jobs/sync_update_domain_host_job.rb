class SyncUpdateDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, domain_host, old_domain_host_name, retry_count = 0
    domain = domain_host.product.domain

    domain_url      = "#{url}/domains/#{domain.name}"
    domain_host_url = "#{domain_url}/hosts"

    raise 'Max retry reached!' unless retry_count < MAX_SYNC_RETRY_COUNT

    unless check domain_url, token: domain.partner.name
      SyncUpdateDomainHostJob.perform_later url, domain_host, old_domain_host_name, (retry_count + 1)

      return
    end

    body = {
      name: domain_host.name,
      old_name: old_domain_host_name
    }

    post domain_host_url, body, token: domain.partner.name
  end
end

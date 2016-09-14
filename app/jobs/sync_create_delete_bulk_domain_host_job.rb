class SyncCreateDeleteBulkDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, domain, domain_host_for_delete, domain_host_for_add, retry_count = 0
    domain_url      = "#{url}/domains/#{domain.name}"
    domain_host_url = "#{domain_url}/hosts"

    raise 'Max retry reached!' unless retry_count < MAX_SYNC_RETRY_COUNT

    unless check domain_url, token: domain.partner.name
      SyncCreateDeleteBulkDomainHostJob.perform_later url, domain, domain_host_for_delete, domain_host_for_add, (retry_count + 1)

      return
    end

    body = {
      bulk: true,
      domain_host_add: domain_host_for_add,
      domain_host_delete: domain_host_for_delete
    }

    post domain_host_url, body, token: domain.partner.name
  end
end

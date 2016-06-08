class SyncDeleteDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, domain, name
    delete "#{url}/domains/#{domain}/hosts/#{name}", token: partner.name
  end
end

class SyncDeleteDomainHostJob < ApplicationJob
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/domains"

  def perform partner, domain, name
    delete url: SyncDeleteDomainHostJob.url(domain, name), token: partner.name
  end

  def self.url domain, name
    "#{URL}/#{domain}/hosts/#{name}"
  end
end

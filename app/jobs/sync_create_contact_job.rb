class SyncCreateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/contacts"

  def perform partner, params
    post url: URL, params: params, token: partner.name
  end
end

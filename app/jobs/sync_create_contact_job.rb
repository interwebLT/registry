class SyncCreateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, params
    post "#{url}/contacts", params, token: partner.name
  end
end

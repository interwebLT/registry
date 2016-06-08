class SyncOrderJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, params
    post "#{url}/orders", params, token: partner.name
  end
end

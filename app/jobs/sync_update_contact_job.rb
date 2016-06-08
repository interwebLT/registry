class SyncUpdateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, handle, params
    patch "#{url}/contacts/#{handle}", params, token: partner.name
  end
end

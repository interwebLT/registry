class SyncUpdateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, partner, handle, params
    patch url: "#{url}/contacts/#{handle}", params: params, token: partner.name
  end
end

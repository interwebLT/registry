class SyncUpdateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/contacts"

  def perform partner, handle, params
    patch url: SyncUpdateContactJob.url(handle), params: params, token: partner.name
  end

  def self.url id
    "#{URL}/#{id}"
  end
end

class SyncOrderJob < ActiveJob::Base
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/orders"

  def perform params
    HTTParty.post URL, body: params.to_json, headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
  end
end

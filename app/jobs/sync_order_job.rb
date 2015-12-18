class SyncOrderJob < ActiveJob::Base
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/orders"

  def perform partner, params
    headers = {
      'Authorization' => "Token token=#{partner}",
      'Content-Type'  => 'application/json',
      'Accept'        => 'application/json'
    }

    HTTParty.post URL, body: params.to_json, headers: headers
  end
end

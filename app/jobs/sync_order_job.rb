class SyncOrderJob < ActiveJob::Base
  queue_as :sync_changes

  def perform params
    HTTParty.post 'http://test.host/orders', body: params.to_json
  end
end

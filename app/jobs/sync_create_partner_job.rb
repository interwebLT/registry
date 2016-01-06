class SyncCreatePartnerJob < ApplicationJob
  queue_as :sync_registry_changes

  URL = "#{Rails.configuration.x.cocca_api_host}/partners"

  def perform username, password
    params = {
      name:  username,
      password:  password
    }

    post url: URL, params: params
  end
end

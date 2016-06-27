class SyncCreateHostJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, host
    body = {
      name: host.name
    }

    post "#{url}/hosts", body, token: host.partner.name
  end
end

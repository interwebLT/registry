class SyncRenewDomainJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, order
    order_detail = order.order_details.first

    body = {
      currency_code:  'USD',
      ordered_at:     order.ordered_at.iso8601,
      order_details:  [
        {
          type:               'domain_renew',
          domain:             order_detail.domain,
          period:             order_detail.period,
          current_expires_at: order_detail.current_expires_at.iso8601
        }
      ]
    }

    post "#{url}/orders", body, token: order.partner.name
  end
end

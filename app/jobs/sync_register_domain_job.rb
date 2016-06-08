class SyncRegisterDomainJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, order
    order_detail = order.order_details.first

    body = {
      currency_code:  'USD',
      ordered_at:     order.ordered_at.iso8601,
      order_details:  [
        {
          type:               'domain_create',
          domain:             order_detail.domain,
          authcode:           order_detail.authcode,
          period:             order_detail.period,
          registrant_handle:  order_detail.registrant_handle
        }
      ]
    }

    post "#{url}/orders", body, token: order.partner.name
  end
end

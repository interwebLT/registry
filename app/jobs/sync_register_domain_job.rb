class SyncRegisterDomainJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, order, retry_count = 0
    order_detail = order.order_details.first

    registrant_url  = "#{url}/contacts/#{order_detail.registrant_handle}"
    orders_url      = "#{url}/orders"

    unless check registrant_url, token: order.partner.name
      SyncRegisterDomainJob.perform_later url, order, (retry_count + 1)

      return
    end

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

    post orders_url, body, token: order.partner.name
  end
end

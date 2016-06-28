class SyncRenewDomainJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, order, retry_count = 0
    order_detail = order.order_details.first

    domain_url  = "#{url}/domains/#{order_detail.domain}"
    orders_url  = "#{url}/orders"

    unless check domain_url, token: order.partner.name
      SyncRenewDomainJob.perform_later url, order, (retry_count + 1)

      return
    end

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

    post orders_url, body, token: order.partner.name
  end
end

require 'test_helper'

describe OrderSerializer do
  subject { OrderSerializer.new(order).serializable_hash }

  let(:order) { create :register_domain_order }

  let(:expected_json) {
    order_detail = order.order_details.first

    {
      id: order.id,
      partner: order.partner.name,
      order_number: order.order_number,
      total_price: order.total_price.to_f,
      fee: order.fee.to_f,
      ordered_at: order.ordered_at,
      status: order.status,
      currency_code: 'USD',
      order_details: [
        {
          type: 'domain_create',
          price: order_detail.price.to_f,
          domain: order_detail.domain,
          period: order_detail.period,
          registrant_handle: order_detail.registrant_handle,
          registered_at: order_detail.registered_at.iso8601
        }
      ]
    }
  }

  specify { subject.must_equal expected_json }
end

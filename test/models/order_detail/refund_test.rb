require 'test_helper'

describe OrderDetail::Refund do
  describe :associations do
    subject { create :refund_order_detail }

    specify { subject.refunded_order_detail.wont_be_nil }
  end

  describe :valid? do
    subject { create :refund_order_detail }

    before do
      subject.refunded_order_detail = nil

      subject.valid?
    end

    specify { subject.valid?.must_equal false }
    specify { subject.errors.count.must_equal 1 }
    specify { subject.errors[:refunded_order_detail].must_equal ['invalid'] }
  end

  describe :complete! do
    subject { create :pending_refund_order_detail }

    before do
      domain
      domain.renew subject.refunded_order_detail.period

      subject.complete!
    end

    let(:domain) {
      create :domain, name: subject.refunded_order_detail.domain,
                      expires_at: expires_at
    }

    let(:expires_at) { '2015-04-24 2:30 PM'.in_time_zone }

    specify { Domain.named(domain.name).expires_at.must_equal expires_at }
    specify { subject.complete?.must_equal true }
  end

  describe :execute do
    subject { OrderDetail::Refund.execute order_id: order_detail.order.id }

    before do
      domain
      domain.renew order_detail.period

      subject
    end

    let(:order) { create :renew_domain_order }
    let(:order_detail) { order.order_details.first }
    let(:domain) { create :domain, name: order_detail.domain, expires_at: expires_at }
    let(:expires_at) { '2015-04-24 2:30 PM'.in_time_zone }

    specify { OrderDetail.find(order_detail.id).reversed?.must_equal true }
    specify { Domain.named(order_detail.domain).expires_at.must_equal expires_at }
  end

  describe :as_json do
    subject { build :refund_order_detail }

    let(:expected_json) {
      {
        type: 'refund',
        price:  -35.00,
        refunded_order_detail: {
          type: 'domain_renew',
          price:  35.00,
          domain: 'domain.ph',
          object: nil,
          period: 1,
          renewed_at: '2015-02-14T01:01:00Z'
        }
      }
    }

    specify { subject.as_json.must_equal expected_json }
  end
end

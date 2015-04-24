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
end
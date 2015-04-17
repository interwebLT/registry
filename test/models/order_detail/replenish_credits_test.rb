require 'test_helper'

describe OrderDetail::ReplenishCredits do
  describe :build do
    subject { OrderDetail.build(params, partner) }

    let(:partner) { create :complete_partner }

    let(:params) {
      {
        type: OrderDetail::ReplenishCredits.new.action,
        credits: 150.00
      }
    }

    specify { subject.valid?.must_equal true }
    specify { subject.must_be_kind_of OrderDetail::ReplenishCredits }
    specify { subject.price.must_equal 150.00.money }
    specify { subject.credits.must_equal 150.00.money }

    specify { subject.domain.must_be_nil }
    specify { subject.registrant_handle.must_be_nil }
  end

  describe :as_json do
    subject { order_detail.as_json }

    let(:order_detail) { create :replenish_credits_order_detail }

    let(:expected_json) {
      {
        type: 'credits',
        price: 150.00
      }
    }

    specify { subject.must_equal expected_json }
  end

  describe :complete! do
    subject { create :replenish_credits_order_detail }

    before do
      subject.complete!
    end

    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    specify { subject.complete?.must_equal true }
    specify { latest_ledger_entry.credits.must_equal BigDecimal.new(150) }
    specify { latest_ledger_entry.activity_type.must_equal 'topup' }
  end

  describe :execute do
    subject { OrderDetail::ReplenishCredits.execute partner: partner, credits: credits }

    before do
      subject
    end

    let(:partner) { create :partner }
    let(:credits) { 123.45 }

    specify { OrderDetail.last.must_be_kind_of OrderDetail::ReplenishCredits }
    specify { OrderDetail.last.complete?.must_equal true }
    specify { OrderDetail.last.price.must_equal credits.money }
    specify { OrderDetail.last.credits.must_equal credits.money }

    specify { OrderDetail.last.order.total_price.must_equal credits.money }
    specify { OrderDetail.last.order.complete?.must_equal true }

    specify { partner.credits.last.credits.must_equal credits }
    specify { partner.credits.last.activity_type.must_equal 'topup' }
  end
end

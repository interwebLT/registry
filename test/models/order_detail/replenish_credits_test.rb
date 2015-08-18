require 'test_helper'

describe OrderDetail::ReplenishCredits do
  describe :build do
    subject { OrderDetail.build(params, partner) }

    let(:partner) { create :complete_partner }

    let(:params) {
      {
        type: OrderDetail::ReplenishCredits.new.action,
        credits: 150.00,
        remarks: 'this is a remark'
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
    subject { build :replenish_credits_order_detail }

    let(:expected_json) {
      {
        type: 'credits',
        object: nil,
        price: 150.00
      }
    }

    specify { subject.as_json.must_equal expected_json }
  end

  describe :complete! do
    subject { create :replenish_credits_order_detail }

    before do
      subject.complete!
    end

    let(:latest_ledger_entry) { subject.order.partner.credits.last }

    specify { subject.complete?.must_equal true }
    specify { latest_ledger_entry.amount.must_equal 150.00.money }
    specify { latest_ledger_entry.activity_type.must_equal 'topup' }
  end

  describe :execute do
    subject { OrderDetail.last }

    before do
      OrderDetail::ReplenishCredits.execute partner: partner.name,
                                            credits: credits,
                                            remarks: 'this is a remark',
                                            at: replenished_at
    end

    let(:partner) { create :partner }
    let(:credits) { 123.45 }
    let(:replenished_at) { '2015-08-10 4:30 PM'.in_time_zone }

    specify { subject.must_be_kind_of OrderDetail::ReplenishCredits }
    specify { subject.complete?.must_equal true }
    specify { subject.price.must_equal credits.money }
    specify { subject.credits.must_equal credits.money }

    specify { subject.order.total_price.must_equal credits.money }
    specify { subject.order.complete?.must_equal true }
    specify { subject.order.ordered_at.must_equal replenished_at }

    specify { partner.credits.last.amount.must_equal credits.money }
    specify { partner.credits.last.activity_type.must_equal 'topup' }
  end
end

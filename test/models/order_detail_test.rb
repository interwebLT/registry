require 'test_helper'

describe OrderDetail do
  describe :associations do
    subject { create :order_detail_for_domain }

    specify { subject.order.wont_be_nil }
    specify { subject.product.wont_be_nil }
  end

  describe :complete? do
    specify { OrderDetail.new(status: OrderDetail::COMPLETE_ORDER_DETAIL).complete?.must_equal true }
    specify { OrderDetail.new(status: OrderDetail::PENDING_ORDER_DETAIL).complete?.must_equal false }
    specify { OrderDetail.new(status: OrderDetail::ERROR_ORDER_DETAIL).complete?.must_equal false }
  end

  describe :error? do
    specify { OrderDetail.new(status: OrderDetail::ERROR_ORDER_DETAIL).error?.must_equal true }
    specify { OrderDetail.new(status: OrderDetail::COMPLETE_ORDER_DETAIL).error?.must_equal false }
    specify { OrderDetail.new(status: OrderDetail::PENDING_ORDER_DETAIL).error?.must_equal false }
  end

  describe :complete do
    subject { create :order_detail }

    specify { subject.complete!.must_equal true }
  end

  describe :build do
    subject { OrderDetail.build(params, partner) }

    before do
      subject.order = order
    end

    let(:order) { create :order }
    let(:partner) { order.partner }

    context :when_successful do
      let(:params) {
        {
          type: OrderDetail::ReplenishCredits.new.action,
          credits: 150.00
        }
      }

      specify { subject.order.order_details.wont_be_empty }
    end

    context :when_invalid_params do
      let(:params) {
        {
          type: 'invalid',
          domain: 'domains.ph',
          period: 2,
          registrant_handle: 'domains_registrant'
        }
      }

      specify { subject.valid?.wont_equal true }
    end

    context :when_partner_nil do
      let(:partner) { nil }

      let(:params) {
        {
          type: OrderDetail::ReplenishCredits.new.action,
          credits: 150.00
        }
      }

      specify { subject.wont_be_nil }
    end
  end

  describe :valid do
    specify { build(:order_detail, type: nil).valid?.wont_equal true }
    specify { build(:order_detail, price: nil).valid?.wont_equal true }
  end
end

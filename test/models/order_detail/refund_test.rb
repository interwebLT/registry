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
end

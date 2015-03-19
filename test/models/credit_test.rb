require 'test_helper'

describe Credit do
  describe :associations do
    subject { create :credit }

    specify { subject.partner.wont_be_nil }
    specify { subject.order.wont_be_nil }
  end
end

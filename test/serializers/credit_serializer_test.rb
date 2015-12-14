require 'test_helper'

describe CreditSerializer do
  subject { CreditSerializer.new(credit).serializable_hash }

  let(:credit) { create :replenish_credits_order }

  specify { subject[:id].wont_be_nil }
  specify { subject[:partner].must_match /alpha[0-9]*/ }
  specify { subject[:order_number].wont_be_nil }
  specify { subject[:credits].must_equal 150.00 }
  specify { subject[:credited_at].must_equal '2015-02-27T14:30:00Z' }
  specify { subject[:created_at].wont_be_nil }
  specify { subject[:updated_at].wont_be_nil }
end

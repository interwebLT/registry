require 'test_helper'

describe PartnerPricingSerializer do
  subject { PartnerPricingSerializer.new(pricing).serializable_hash }

  let(:pricing) { create :partner_pricing }

  specify { subject[:id].wont_be_nil }
  specify { subject[:action].must_equal 'domain_create' }
  specify { subject[:period].must_equal 1 }
  specify { subject[:price].must_equal 35.00 }
end

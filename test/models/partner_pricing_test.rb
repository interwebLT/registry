require 'test_helper'

describe PartnerPricing do
  describe :associations do
    subject { build :partner_pricing }

    specify { subject.partner.wont_be_nil }
  end
end

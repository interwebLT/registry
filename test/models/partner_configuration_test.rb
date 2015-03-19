require 'test_helper'

describe PartnerConfiguration do
  describe :associations do
    subject { create :partner_configuration }

    specify { subject.partner.wont_be_nil }
  end
end

require 'test_helper'

describe DeletedDomain do
  describe :associations do
    subject { create :complete_deleted_domain }

    specify { subject.product.wont_be_nil }
    specify { subject.partner.wont_be_nil }
    specify { subject.registrant.wont_be_nil }
    specify { subject.admin_contact.wont_be_nil }
    specify { subject.billing_contact.wont_be_nil }
    specify { subject.tech_contact.wont_be_nil }
  end
end


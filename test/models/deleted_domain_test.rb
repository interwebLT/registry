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

  describe :restore! do
    subject { create :deleted_domain, name: domain_name }

    let(:domain_name) { 'test.ph' }

    before do
      subject.restore!
    end

    specify { DeletedDomain.exists?(name: domain_name).wont_equal true }
    specify { Domain.exists?(name: domain_name).must_equal true }
  end
end


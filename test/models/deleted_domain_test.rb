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

      @restored = Domain.find_by name: domain_name
    end

    specify { DeletedDomain.exists?(name: domain_name).wont_equal true }
    specify { Domain.exists?(name: domain_name).must_equal true }

    specify { subject.ok.must_equal @restored.ok }
    specify { subject.inactive.must_equal @restored.inactive }
    specify { subject.client_hold.must_equal @restored.client_hold }
    specify { subject.client_update_prohibited.must_equal @restored.client_update_prohibited }
    specify { subject.client_transfer_prohibited.must_equal @restored.client_transfer_prohibited }
    specify { subject.client_renew_prohibited.must_equal @restored.client_renew_prohibited }
    specify { subject.client_delete_prohibited.must_equal @restored.client_delete_prohibited }
  end
end


require 'test_helper'

describe DomainInfoSerializer do
  subject { DomainInfoSerializer.new(domain).serializable_hash }

  context :when_contact_registrant_only do
    let(:domain) { create :domain }

    before do
      create :domain_host, product: domain.product, name: 'ns3.domains.ph'
      create :domain_host, product: domain.product, name: 'ns4.domains.ph'
    end

    specify { subject[:activities].wont_be_empty }
    specify { subject[:hosts].wont_be_empty }

    specify { subject.has_key?(:admin_contact).must_equal true }
    specify { subject.has_key?(:billing_contact).must_equal true }
    specify { subject.has_key?(:tech_contact).must_equal true }

    specify { subject[:admin_contact].must_be_nil }
    specify { subject[:billing_contact].must_be_nil }
    specify { subject[:tech_contact].must_be_nil }
  end

  context :when_all_contacts do
    let(:domain) { create :complete_domain }

    specify { subject[:admin_contact].wont_be_nil }
    specify { subject[:billing_contact].wont_be_nil }
    specify { subject[:tech_contact].wont_be_nil }
  end
end

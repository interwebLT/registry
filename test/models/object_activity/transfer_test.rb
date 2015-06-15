require 'test_helper'

describe ObjectActivity::Transfer do
  describe :associations do
    subject { create :transfer_domain_activity }

    specify { subject.losing_partner.wont_be_nil }
  end

  describe :valid? do
    subject { create :transfer_domain_activity }

    before do
      domain = create :domain

      subject.product = domain.product
    end

    context :when_no_product do
      before do
        subject.product = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:product].must_equal ['invalid'] }
    end

    context :when_no_losing_partner do
      before do
        subject.losing_partner = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:losing_partner].must_equal ['invalid'] }
    end
  end

  describe :as_json do
    subject { create :transfer_domain_activity }

    before do
      domain = create :domain

      subject.product = domain.product
    end

    let(:expected_json) {
      {
        id: 1,
        type: 'transfer',
        partner:     {
          id: 1,
          name: 'alpha',
          organization: 'Company',
          credits: 0.00,
          site: 'http://alpha.ph',
          nature: 'Alpha Business',
          representative: 'Alpha Guy',
          position: 'Position',
          street: 'Alpha Street',
          city: 'Alpha City',
          state: 'Alpha State',
          postal_code: '1234',
          country_code: 'PH',
          phone: '+63.1234567',
          fax: '+63.1234567',
          email: 'alpha@alpha.ph',
          local: true,
          admin: false
        },
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 1,
          type: 'domain',
          name: 'domain.ph'
        },
        losing_partner: 'other_partner'
      }
    }

    specify { Json.lock_values(subject.as_json).must_equal expected_json }
  end
end

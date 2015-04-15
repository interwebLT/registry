require 'test_helper'

describe ObjectActivity::Create do
  describe :valid? do
    subject { create :create_domain_activity }

    context :when_no_registrant_handle do
      before do
        subject.registrant_handle = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_no_authcode do
      before do
        subject.authcode = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:authcode].must_equal ['invalid'] }
    end

    context :when_no_expires_at do
      before do
        subject.expires_at = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:expires_at].must_equal ['invalid'] }
    end
  end

  describe :as_json do
    subject { create :create_domain_activity }

    before do
      domain = create :domain

      subject.product = domain.product
    end

    let(:expected_json) {
      {
        id: 1,
        type: 'create',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 1,
          type: 'domain',
          name: 'domain.ph'
        }
      }
    }

    specify { Json.lock_values(subject.as_json).must_equal expected_json }
  end
end

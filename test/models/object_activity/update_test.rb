require 'test_helper'

describe ObjectActivity::Update do
  describe :valid? do
    subject { create :update_domain_activity }

    context :when_property_changed_missing do
      before do
        subject.property_changed = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:property_changed].must_equal ['invalid'] }
    end

    context :when_old_value_missing_but_value_present do
      before do
        subject.old_value = nil
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_value_missing_but_old_value_present do
      before do
        subject.value = nil
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_both_old_value_and_value_missing do
      before do
        subject.old_value = nil
        subject.value = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:value].must_equal ['invalid'] }
    end
  end

  describe :as_json do
    subject { create :update_domain_activity }

    before do
      domain = create :domain

      subject.product = domain.product
    end

    let(:expected_json) {
      {
        id: 1,
        type: 'update',
        activity_at: '2015-01-01T00:00:00Z',
        object: {
          id: 1,
          type: 'domain',
          name: 'domain.ph'
        },
        property_changed: 'expires_at',
        old_value: '2015-04-15T12:00:00Z',
        new_value: '2017-04-15T12:00:00Z',
      }
    }

    specify { Json.lock_values(subject.as_json).must_equal expected_json }
  end
end

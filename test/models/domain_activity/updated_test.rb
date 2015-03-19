require 'test_helper'

describe DomainActivity::Updated do
  subject { create :update_activity }

  describe :valid? do
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
    subject { object_activity.as_json }

    let(:object_activity) {
      create :update_activity, activity_at: '2015-03-03 1:00'.in_time_zone
    }

    specify { subject[:id].must_equal object_activity.id }
    specify { subject[:type].must_equal 'update' }
    specify { subject[:activity_at].must_equal '2015-03-03T01:00:00Z' }
    specify { subject[:object].wont_be_nil }
    specify { subject[:property_changed].must_equal 'registrant' }
    specify { subject[:old_value].must_equal 'old_registrant' }
    specify { subject[:new_value].must_equal 'new_registrant' }

    specify { subject[:object][:id].wont_be_nil }
    specify { subject[:object][:type].must_equal 'domain' }
    specify { subject[:object][:name].must_equal 'domain.ph' }
  end
end

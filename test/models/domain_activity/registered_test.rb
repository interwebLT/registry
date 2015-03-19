require 'test_helper'

describe DomainActivity::Registered do
  describe :as_json do
    subject { object_activity.as_json }

    let(:object_activity) {
      create :create_activity, activity_at: '2015-02-28 14:30'.in_time_zone
    }

    specify { subject[:id].must_equal object_activity.id }
    specify { subject[:type].must_equal 'create' }
    specify { subject[:activity_at].must_equal '2015-02-28T14:30:00Z' }
    specify { subject[:object].wont_be_nil }

    specify { subject[:object][:id].wont_be_nil }
    specify { subject[:object][:type].must_equal 'domain' }
    specify { subject[:object][:name].must_equal 'domain.ph' }
  end
end

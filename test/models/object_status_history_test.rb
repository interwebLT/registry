require 'test_helper'

describe ObjectStatusHistory do
  describe :associations do
    subject { create :object_status_history }

    specify { subject.object_status.wont_be_nil }
  end
end

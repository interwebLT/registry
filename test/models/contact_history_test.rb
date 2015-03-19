require 'test_helper'

describe ContactHistory do
  describe :associations do
    subject { create :contact_history }

    specify { subject.contact.wont_be_nil }
    specify { subject.partner.wont_be_nil }
  end
end

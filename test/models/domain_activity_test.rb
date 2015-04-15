require 'test_helper'

describe DomainActivity do
  describe :associations do
    subject { create :domain_activity }

    specify { subject.domain.wont_be_nil }
  end
end

require 'test_helper'

describe DomainActivity do
  describe :associations do
    subject { create :domain_activity }

    specify { subject.domain.wont_be_nil }
  end

  describe :latest do
    subject { DomainActivity.latest }

    before do
      domain = create :domain

      create :update_activity, domain: domain
    end

    specify { subject.count.must_equal 2 }
    specify { subject[0].must_be_instance_of DomainActivity::Updated }
    specify { subject[1].must_be_instance_of DomainActivity::Registered }
  end
end

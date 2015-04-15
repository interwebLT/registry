require 'test_helper'

describe DomainHost do
  describe :associations do
    before do
      create :host
    end

    subject { create :domain_host, product: product }

    let(:domain) { create :domain }
    let(:product) { domain.product }

    specify { subject.product.wont_be_nil }
  end

  describe :valid? do
    subject { build :domain_host, product: product }

    let(:domain) { create :domain }
    let(:product) { domain.product }

    context :when_name_missing do
      before do
        subject.name = nil

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:name].must_equal ['invalid'] }
    end

    context :when_name_exists do
      before do
        create :host
        create :domain_host, product: product

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:name].must_equal ['already_exists'] } end

    context :when_name_exists_in_other_domain do
      before do
        create :host

        domain = create :domain,  registrant: subject.product.domain.registrant,
                                  name: 'other_domain',
                                  extension: '.ph'

        create :domain_host, product: domain.product

        subject.valid?
      end

      specify { subject.valid?.must_equal true }
      specify { subject.errors.must_be_empty }
    end

    # context :when_name_does_not_match_existing_host do
    #   before do
    #     subject.valid?
    #   end

    #   specify { subject.valid?.wont_equal true }
    #   specify { subject.errors.count.must_equal 1 }
    #   specify { subject.errors[:name].must_equal ['invalid'] }
    # end
  end

  describe :callbacks do
    before do
      domain = create :domain
      create :domain_host, product: domain.product
    end

    let(:activities) { Domain.last.domain_activities }
    let(:object_status) { Domain.last.product.object_status }

    context :when_adding_domain_host do
      specify { activities.count.must_equal 4 }

      specify { activities[1].must_be_instance_of ObjectActivity::Update }
      specify { activities[1].property_changed.must_equal 'domain_host' }
      specify { activities[1].old_value.must_be_nil }
      specify { activities[1].value.must_equal 'ns5.domains.ph' }

      specify { object_status.ok.must_equal true }
      specify { object_status.inactive.must_equal false }
    end

    context :when_removing_domain_host do
      before do
        DomainHost.last.destroy!
      end

      specify { activities.count.must_equal 5 }

      specify { activities[4].must_be_instance_of ObjectActivity::Update }
      specify { activities[4].property_changed.must_equal 'domain_host' }
      specify { activities[4].old_value.must_equal 'ns5.domains.ph' }
      specify { activities[4].value.must_be_nil }

      specify { object_status.ok.must_equal true }
      specify { object_status.inactive.must_equal false }
    end
  end
end


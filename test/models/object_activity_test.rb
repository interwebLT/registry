require 'test_helper'

describe ObjectActivity do
  describe :associations do
    subject { create :object_activity, type: ObjectActivity::Create }

    specify { subject.partner.wont_be_nil }
    specify { subject.product.wont_be_nil }
  end

  describe :valid? do
    subject { create :object_activity, type: ObjectActivity::Create }

    context :when_no_partner do
      before do
        subject.partner = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:partner].must_equal ['invalid'] }
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

    context :when_no_activity_at do
      before do
        subject.activity_at = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:activity_at].must_equal ['invalid'] }
    end
  end

  describe :latest do
    subject { ObjectActivity.latest }

    before do
      domain = create :domain

      create :update_domain_activity, product: domain.product
    end

    specify { subject.count.must_equal 2 }
    specify { subject[0].must_be_instance_of ObjectActivity::Update }
    specify { subject[1].must_be_instance_of ObjectActivity::Create }
  end
end

require 'test_helper'

describe HostAddress do
  describe :associations do
    subject { create :host_address }

    specify { subject.host.wont_be_nil }
  end

  describe :valid? do
    subject { build :host_address, host: host }

    let(:host) { create :host }

    context :when_address_blank do
      before do
        subject.address = ''

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:address].must_equal ['invalid'] }
    end

    context :when_type_blank do
      before do
        subject.type = ''

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:type].must_equal ['invalid'] }
    end

    context :when_type_blank do
      before do
        subject.type = 'v5'

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:type].must_equal ['invalid'] }
    end

    context :when_address_exists do
      before do
        create :host_address, host: host

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:address].must_equal ['already_exists'] }
    end

    context :when_address_exists_in_other_host do
      before do
        host = create :host, name: 'ns6.domains.ph'
        create :host_address, host: host

        subject.valid?
      end

      specify { subject.valid?.must_equal true }
      specify { subject.errors.must_be_empty }
    end
  end
end

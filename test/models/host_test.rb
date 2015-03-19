require 'test_helper'

describe Host do
  describe :associations do
    subject { create :host }

    before do
      create :host_address, host: subject, address: '123.456.789.001'
      create :host_address, host: subject, address: '123.456.789.002'
    end

    specify { subject.partner.wont_be_nil }
    specify { subject.host_addresses.wont_be_empty }
  end

  describe :valid? do
    subject { build :host }

    context :when_partner_does_not_exist do
      before do
        subject.partner_id = -1

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:partner].must_equal ['invalid'] }
    end

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

        subject.valid?
      end

      specify { subject.valid?.wont_equal true }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:name].must_equal ['already_exists'] }
    end
  end
end


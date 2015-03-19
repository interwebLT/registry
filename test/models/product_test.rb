require 'test_helper'

describe Product do
  subject { create :product }

  describe :associations do
    before do
      contact = create :contact

      create :domain, product: subject, registrant: contact
      create :order_detail, product: subject
    end

    specify { subject.order_details.wont_be_empty }
    specify { subject.domain.wont_be_nil }
    specify { subject.object_status.wont_be_nil }
  end

  describe :callbacks do
    subject { create :product }

    specify { subject.object_status.wont_be_nil }
  end
end

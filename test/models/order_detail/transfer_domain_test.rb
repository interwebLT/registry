require 'test_helper'

describe OrderDetail::TransferDomain do
  describe :as_json do
    subject { order_detail.as_json }

    let(:order_detail) { build :transfer_domain_order_detail }

    let(:expected_json) {
      {
        type: 'domain_transfer',
        price: 15.00,
        domain: 'domain.ph'
      }
    }

    specify { subject.must_equal expected_json }
  end
end

RSpec.describe OrderDetail::RegisterDomain do
  describe '#as_json_request' do
    subject { FactoryGirl.create(:register_domain_order_detail).as_json_request }

    let(:expected_json) {
      {
        currency_code: 'USD',
        ordered_at: '2015-02-27T14:30:00Z',
        order_details: [
          {
            type: 'domain_create',
            domain: 'domains.ph',
            authcode: 'ABC123',
            period: 2,
            registrant_handle: 'domains_r'
          }
        ]
      }
    }

    it { is_expected.to eql expected_json }
  end
end

require 'test_helper'

describe HostSerializer do
  subject { HostSerializer.new(host).serializable_hash }

  context :with_no_host_addresses do
    let(:host) { build :host }

    specify { subject[:id].must_equal host.id }
    specify { subject[:partner].must_equal host.partner.name }
    specify { subject[:name].must_equal host.name }
    specify { subject[:created_at].must_equal host.created_at }
    specify { subject[:updated_at].must_equal host.updated_at }
    specify { subject[:host_addresses].must_be_empty }
  end

  context :with_host_addresses do
    let(:host) { create :host_with_addresses }

    specify { subject[:host_addresses].wont_be_empty }
    specify { subject[:host_addresses].first.must_equal({ address: '123.456.789.001', type: 'v4' }) }
    specify { subject[:host_addresses].last.must_equal({ address: '123.456.789.002', type: 'v4' }) }
  end
end

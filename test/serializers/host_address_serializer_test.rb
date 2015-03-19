require 'test_helper'

describe HostAddressSerializer do
  subject { HostAddressSerializer.new(host_address).serializable_hash }

  let (:host_address) { build :host_address }

  specify { subject[:id].must_equal host_address.id }
  specify { subject[:address].must_equal host_address.address }
  specify { subject[:type].must_equal host_address.type }
  specify { subject[:created_at].must_equal host_address.created_at }
  specify { subject[:updated_at].must_equal host_address.updated_at }
end

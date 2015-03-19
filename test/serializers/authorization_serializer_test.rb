require 'test_helper'

describe AuthorizationSerializer do
  subject { AuthorizationSerializer.new(authorization).serializable_hash }

  let(:authorization) { build :authorization }

  specify { subject[:id].must_equal authorization.id }
  specify { subject[:token].must_equal authorization.token }
end

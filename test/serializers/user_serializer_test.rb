require 'test_helper'

describe UserSerializer do
  subject { UserSerializer.new(user).serializable_hash }

  let(:user) { create :user, token: 'abcd123456' }

  specify { subject[:id].must_equal user.id }
  specify { subject[:username].must_equal user.username }
  specify { subject[:token].must_equal user.token }
  specify { subject[:partner_name].must_equal user.partner.name }
  specify { subject[:credits].must_equal user.partner.current_balance }
  specify { subject[:transactions_allowed].must_equal true }
  specify { subject[:admin].must_equal false }
end

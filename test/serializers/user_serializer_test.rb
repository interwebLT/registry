require 'test_helper'

describe UserSerializer do
  subject { UserSerializer.new(user).serializable_hash }

  let(:user) { create :user, token: 'abcd123456' }

  let(:expected_json) {
    {
      id:                   user.id,
      username:             user.username,
      token:                user.token,
      partner_id:           user.partner.id,
      partner_name:         user.partner.name,
      credits:              user.partner.current_balance.to_f,
      transactions_allowed: true,
      admin:                false,
      staff:                false,
      email:                user.email
    }
  }

  specify { subject.must_equal expected_json }
end

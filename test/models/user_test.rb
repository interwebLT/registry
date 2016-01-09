require 'test_helper'

describe User do
  describe :password do
    it 'is encrypted upon being set' do
      user = User.new
      user.encrypted_password.must_be_nil
      user.password = 'password'
      user.encrypted_password.wont_be_nil
      user.encrypted_password.wont_equal 'password'
    end

    it 'authenticates properly' do
      user = User.new

      user.password = 'password'

      user.password_matches('password').must_equal true
      user.password_matches('wrong').must_equal false
    end

    it 'salt changes when it is set' do
      user = User.new
      salt = user.salt
      user.password = 'password'
      user.salt.wont_equal salt
    end
  end

  describe :associations do
    subject { create :user_with_authorizations }

    specify { subject.authorizations.wont_be_empty }
    specify { subject.partner.wont_be_nil }
  end

  describe :authorize do
    subject { User.authorize! authorization.token }

    let(:current_user) { create :user }
    let(:authorization) { current_user.authorizations.create }

    context :when_authorized do
      specify { subject.must_equal authorization }
    end

    context :when_timed_out do
      before do
        authorization.update! last_authorized_at: Time.current + User::TIMEOUT
      end

      specify { subject.must_be_nil }
    end
  end
end

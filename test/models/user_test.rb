require 'test_helper'

describe User do
  describe :associations do
    subject { create :user_with_authorizations }

    specify { subject.authorizations.wont_be_empty }
    specify { subject.partner.wont_be_nil }
  end

  describe :authorize do
    subject { User.authorize! authorization.token }

    let(:current_user) { create :user }

    context :when_authorized do
      let(:authorization) { current_user.authorizations.create }

      specify { subject.must_equal authorization }
    end

    context :when_timed_out do
      let(:authorization) {
        current_user.authorizations.create(updated_at: Time.now + User::TIMEOUT)
      }

      specify { subject.must_be_nil }
    end
  end
end

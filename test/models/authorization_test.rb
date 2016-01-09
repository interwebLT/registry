require 'test_helper'

describe Authorization do
  describe :generate_token do
    subject { Authorization.create type: '' }

    specify { subject.token.wont_be_nil }
  end

  describe :update_last_authorized_at do
    subject { Authorization.create type: '' }

    specify { Authorization.find_by(token: subject.token).updated_at.wont_equal subject.updated_at }
  end
end

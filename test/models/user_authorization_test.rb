require 'test_helper'

describe UserAuthorization do
  describe :associations do
    subject { create :user_authorization }

    specify { subject.user.wont_be_nil }
  end
end

require 'test_helper'

describe UserAuthorization do
  subject { create :user_authorization }

  describe :associations do
    specify { subject.user.wont_be_nil }
  end

  describe :valid? do
    specify { subject.user = nil; subject.valid?.must_equal false }
  end
end

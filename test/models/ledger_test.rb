require 'test_helper'

describe Ledger do
  describe :associations do
    subject { create :ledger }

    specify { subject.partner.wont_be_nil }
  end
end

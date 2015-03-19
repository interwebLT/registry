require 'test_helper'

describe RegistrantSerializer do
  subject { RegistrantSerializer.new(registrant).serializable_hash }

  let(:registrant) { build :registrant }

  specify { subject[:name].must_equal registrant.name }
end

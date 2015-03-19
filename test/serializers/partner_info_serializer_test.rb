require 'test_helper'

describe PartnerInfoSerializer do
  subject { PartnerInfoSerializer.new(partner).serializable_hash }

  let(:partner) { create :complete_partner }

  specify { subject[:default_nameservers].wont_be_empty }
  specify { subject[:default_nameservers].count.must_equal 2 }
  specify { subject[:default_nameservers][0][:name].must_equal 'ns3.domains.ph' }
  specify { subject[:default_nameservers][1][:name].must_equal 'ns4.domains.ph' }

  specify { subject[:pricing].wont_be_empty }
end

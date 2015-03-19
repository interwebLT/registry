require 'test_helper'

describe PartnerSerializer do
  subject { PartnerSerializer.new(partner).serializable_hash }

  let(:partner) { build :partner }

  specify { subject[:id].must_equal partner.id }
  specify { subject[:name].must_equal partner.name }
  specify { subject[:organization].must_equal partner.organization }
  specify { subject[:credits].must_equal partner.current_balance }
  specify { subject[:site].must_equal partner.url }
  specify { subject[:nature].must_equal partner.nature }
  specify { subject[:representative].must_equal partner.representative }
  specify { subject[:position].must_equal partner.position }
  specify { subject[:street].must_equal partner.street }
  specify { subject[:city].must_equal partner.city }
  specify { subject[:postal_code].must_equal partner.postal_code }
  specify { subject[:country_code].must_equal partner.country_code }
  specify { subject[:phone].must_equal partner.voice }
  specify { subject[:fax].must_equal partner.fax }
  specify { subject[:email].must_equal partner.email }
  specify { subject[:local].must_equal true }
  specify { subject[:admin].must_equal false }
end

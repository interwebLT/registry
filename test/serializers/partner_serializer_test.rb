require 'test_helper'

describe PartnerSerializer do
  subject { PartnerSerializer.new(partner).serializable_hash }

  let(:partner) { build :partner }

  let(:expected_json) {
    {
      id:             partner.id,
      name:           partner.name,
      organization:   partner.organization,
      credits:        partner.current_balance.to_f,
      site:           partner.url,
      nature:         partner.nature,
      representative: partner.representative,
      position:       partner.position,
      street:         partner.street,
      city:           partner.city,
      state:          partner.state,
      postal_code:    partner.postal_code,
      country_code:   partner.country_code,
      phone:          partner.voice,
      fax:            partner.fax,
      email:          partner.email,
      local:          partner.local,
      admin:          partner.admin
    }
  }

  specify { subject.must_equal expected_json }
end

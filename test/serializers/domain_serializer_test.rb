require 'test_helper'

describe DomainSerializer do
  subject { DomainSerializer.new(domain).serializable_hash }

  let(:domain) { build :domain }

  let(:expected_json) {
    {
      id: domain.id,
      zone: domain.zone,
      name: domain.name,
      partner:  domain.partner.name,
      registered_at:  domain.registered_at.iso8601,
      expires_at: domain.expires_at.iso8601,
      registrant_handle:  domain.registrant_handle,
      admin_handle: domain.admin_handle,
      billing_handle: domain.billing_handle,
      tech_handle:  domain.tech_handle,
      client_hold:  false,
      client_delete_prohibited: false,
      client_renew_prohibited:  false,
      client_transfer_prohibited: false,
      client_update_prohibited: false,
      expired:  true,
      expiring: false
    }
  }

  specify { subject.must_equal expected_json }
end

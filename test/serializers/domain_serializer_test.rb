require 'test_helper'

describe DomainSerializer do
  subject { DomainSerializer.new(domain).serializable_hash }

  let(:domain) { build :domain }

  specify { subject[:id].must_equal domain.id }
  specify { subject[:zone].must_equal domain.zone }
  specify { subject[:name].must_equal domain.full_name }
  specify { subject[:registered_at].must_equal domain.registered_at }
  specify { subject[:expires_at].must_equal domain.expires_at }
  specify { subject[:registrant].wont_be_nil }
  specify { subject[:registrant_handle].must_equal domain.registrant_handle }
  specify { subject[:admin_handle].must_equal domain.admin_handle }
  specify { subject[:billing_handle].must_equal domain.billing_handle }
  specify { subject[:tech_handle].must_equal domain.tech_handle }
  specify { subject[:client_hold].must_equal false }
  specify { subject[:client_delete_prohibited].must_equal false }
  specify { subject[:client_renew_prohibited].must_equal false }
  specify { subject[:client_transfer_prohibited].must_equal false }
  specify { subject[:client_update_prohibited].must_equal false }
  specify { subject[:expired].must_equal true }
  specify { subject[:expiring].must_equal false }
end

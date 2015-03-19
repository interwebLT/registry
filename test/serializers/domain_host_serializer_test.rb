require 'test_helper'

describe DomainHostSerializer do
  before do
    create :host
  end

  subject { DomainHostSerializer.new(domain_host).serializable_hash }

  let(:domain_host) { build :domain_host, product: domain.product }
  let(:domain) { build :domain }

  specify { subject[:id].must_equal domain_host.id }
  specify { subject[:name].must_equal domain_host.name }
  specify { subject[:created_at].must_equal domain_host.created_at }
  specify { subject[:updated_at].must_equal domain_host.updated_at }
end

require 'test_helper'

describe DomainInfoSerializer do
  subject { DomainInfoSerializer.new(domain).serializable_hash }

  let(:domain) { build :domain }

  before do
    create :domain_host, product: domain.product, name: 'ns3.domains.ph'
    create :domain_host, product: domain.product, name: 'ns4.domains.ph'
  end

  specify { subject[:activities].wont_be_empty }
  specify { subject[:hosts].wont_be_empty }
end

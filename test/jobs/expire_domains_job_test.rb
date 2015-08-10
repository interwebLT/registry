require 'test_helper'

describe ExpireDomainsJob do 
  before do 
    contact = create :contact

    create :domain, registrant: contact
    create :expired_domain, registrant: contact
    create :expired_domain2, registrant: contact
  end

  it "" do 
  end
end 

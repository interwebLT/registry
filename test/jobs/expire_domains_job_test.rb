require 'test_helper'

describe ExpireDomainsJob do 
  before do 
    time = Time.local(2015, 1, 1, 12, 0, 0)
    Timecop.freeze time

    contact = create :contact

    create :domain, registrant: contact
    create :expired_domain, registrant: contact
    create :expired_domain2, registrant: contact
  end

  it "deletes expired domains" do
    Domain.all.length.must_equal 3
    DeletedDomain.all.length.must_equal 0

    ExpireDomainsJob.perform_now

    Domain.all.length.must_equal 1
    Domain.all[0].name.must_equal 'domain.ph'
    DeletedDomain.all.length.must_equal 2 
  end
end 

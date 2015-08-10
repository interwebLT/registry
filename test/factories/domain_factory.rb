FactoryGirl.define do
  factory :domain do
    partner
    product
    name 'domain.ph'
    authcode 'ABCD123'
    registered_at '2014-01-01'.in_time_zone
    expires_at    '2015-01-01'.in_time_zone
    registrant
    ok true
    inactive false
    client_hold false
    client_renew_prohibited false
    client_transfer_prohibited false
    client_update_prohibited false
    client_delete_prohibited false

    factory :complete_domain do
      after :create do |domain, evaluator|
        domain.admin_contact = domain.registrant
        domain.billing_contact = domain.registrant
        domain.tech_contact = domain.registrant

        domain.save
      end
    end

    factory :expired_domain do
      name 'should-expire.ph'
      registered_at '2012-01-01'.in_time_zone
      expires_at    '2013-01-01'.in_time_zone
    end

    factory :expired_domain2 do
      name 'should-expire2.ph'
      registered_at '2012-01-02'.in_time_zone
      expires_at    '2013-01-02'.in_time_zone
    end
  end
end

FactoryGirl.define do
  factory :domain do
    partner
    product
    name 'domain'
    extension '.ph'
    authcode 'ABCD123'
    registered_at '2014-01-01'.in_time_zone
    expires_at    '2015-01-01'.in_time_zone
    registrant

    factory :complete_domain do
      after :create do |domain, evaluator|
        domain.admin_contact = domain.registrant
        domain.billing_contact = domain.registrant
        domain.tech_contact = domain.registrant

        domain.save
      end
    end
  end
end

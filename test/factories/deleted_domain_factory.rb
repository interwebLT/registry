FactoryGirl.define do
  factory :deleted_domain do
    product
    partner
    name  'deleted.ph'
    authcode  'ABC123'
    registrant
    registered_at '2015-01-01'.in_time_zone
    expires_at    '2017-01-01'.in_time_zone
    deleted_at    '2016-01-01'.in_time_zone

    factory :complete_deleted_domain do
      after(:create) do |deleted_domain|
        deleted_domain.admin_contact    = deleted_domain.registrant
        deleted_domain.billing_contact  = deleted_domain.registrant
        deleted_domain.tech_contact     = deleted_domain.registrant

        deleted_domain.save!
      end
    end
  end
end

FactoryGirl.define do
  factory :object_activity do
    partner
    product
    activity_at '2015-04-15 11:30 AM'.in_time_zone

    factory :create_domain_activity, class: ObjectActivity::Create do
      registrant_handle 'contact'
      authcode          'ABC123'
      expires_at        '2017-04-15 11:30 AM'.in_time_zone
    end

    factory :update_domain_activity, class: ObjectActivity::Update do
      property_changed  'expires_at'
      old_value         '2015-04-15T12:00:00Z'
      value             '2017-04-15T12:00:00Z'
    end

    factory :transfer_domain_activity, class: ObjectActivity::Transfer do
      losing_partner
    end
  end
end

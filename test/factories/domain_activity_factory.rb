FactoryGirl.define do
  factory :domain_activity do
    type DomainActivity::Registered.name
    domain
    partner { domain.partner }

    activity_at Time.now

    factory :create_activity, class: DomainActivity::Registered do
      type DomainActivity::Registered
      expires_at  Time.now
      registrant_handle 'handle'
      authcode 'ABC123'
    end

    factory :update_activity, class: DomainActivity::Updated do
      type DomainActivity::Updated
      property_changed 'registrant'
      old_value 'old_registrant'
      value 'new_registrant'
    end
  end
end

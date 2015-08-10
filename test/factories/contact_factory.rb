FactoryGirl.define do
  factory :contact, aliases: [:registrant, :admin_contact, :billing_contact, :tech_contact] do
    partner
    handle 'contact'

    factory :other_contact do
      handle 'other_contact'
    end

    factory :third_contact do
      handle 'third_contact'
    end
  end
end

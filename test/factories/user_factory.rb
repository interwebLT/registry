require 'bcrypt'

FactoryGirl.define do
  factory :user do
    name  'alpha'
    email 'alpha@alpha.org'
    password  'password'
    registered_at Time.current

    factory :admin do
      after :create do |user|
        admin_partner = build :admin_partner
        saved_partner = Partner.find_by name: admin_partner.name

        admin_partner.save! unless saved_partner

        user.update! partner: (saved_partner || admin_partner)
      end
    end

    factory :staff do
    end

    factory :dummy do
    end

    factory :user_with_authorizations do
      transient do
        authorization_count 2
      end

      after :create do |user, evaluator|
        create_list :authorization, evaluator.authorization_count, user: user
      end
    end

    factory :other_user do
      name 'beta'
    end
  end
end

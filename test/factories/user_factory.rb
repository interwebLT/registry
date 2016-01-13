require 'bcrypt'

FactoryGirl.define do
  factory :user do
    partner
    name 'alpha'
    email 'alpha@alpha.org'
    registered_at Time.now

    before :create do |user|
      user.password = 'password'
    end

    factory :admin do
      partner factory: :admin_partner
    end

    factory :staff do
    end

    factory :dummy do
    end

    after :create do |user, evaluator|
      partner = user.partner

      [
        { partner: partner, action: 'domain_create',  period: 1,  price: 35.money },
        { partner: partner, action: 'domain_create',  period: 2,  price: 70.money },
        { partner: partner, action: 'domain_create',  period: 3,  price: 105.money },
        { partner: partner, action: 'domain_create',  period: 4,  price: 140.money },
        { partner: partner, action: 'domain_create',  period: 5,  price: 175.money },
        { partner: partner, action: 'domain_create',  period: 6,  price: 210.money },
        { partner: partner, action: 'domain_create',  period: 7,  price: 245.money },
        { partner: partner, action: 'domain_create',  period: 8,  price: 280.money },
        { partner: partner, action: 'domain_create',  period: 9,  price: 315.money },
        { partner: partner, action: 'domain_create',  period: 10, price: 350.money },
        { partner: partner, action: 'domain_renew', period: 1, price: 32.money },
        { partner: partner, action: 'domain_renew', period: 2, price: 64.money }
      ].each do |params|
        partner.partner_pricings << (create :partner_pricing, params)
      end

      ns3 = 'ns3.domains.ph'
      ns4 = 'ns4.domains.ph'

      create :host, partner: partner, name: ns3 unless Host.exists?(name: ns3)
      create :host, partner: partner, name: ns4 unless Host.exists?(name: ns4)

      create :nameserver_configuration, partner: partner, value: ns3
      create :nameserver_configuration, partner: partner, value: ns4
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
      # partner Partner.find_by(name: 'other_partner')
    end
  end
end

FactoryGirl.define do
  factory :user do
    name 'alpha'
    encrypted_password 'password'
    representative 'Representative'
    organization 'Company'
    nature 'Nature'
    position 'Position'
    street 'Street'
    city 'City'
    state 'State'
    postal_code '1234'
    country_code 'PH'
    url 'http://alpha.org'
    email 'alpha@alpha.org'
    voice '+63.21234567'
    fax '+63.21234567'

    factory :admin do
      name 'admin'
      admin true
    end

    factory :staff do
      name 'staff'
      admin false
      staff true
    end

    factory :dummy do
      name 'beta'
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
        { partner: partner, action: 'domain_create',  period: 10, price: 350.money }
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
  end
end

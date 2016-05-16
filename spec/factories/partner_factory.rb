FactoryGirl.define do
  after :build do |instance|
    if instance.respond_to? :partner
      instance.partner = Partner.find_by(name: 'alpha') || create(:partner)
    end
  end

  factory :partner, aliases: [:complete_partner] do
    initialize_with { Partner.find_by(name: 'alpha') || new }

    name  'alpha'
    organization 'Company'
    url 'http://alpha.ph'
    nature 'Alpha Business'
    representative 'Alpha Guy'
    position 'Position'
    street 'Alpha Street'
    city 'Alpha City'
    state 'Alpha State'
    postal_code '1234'
    country_code 'PH'
    voice '+63.1234567'
    fax '+63.1234567'
    email 'alpha@alpha.ph'
    salt  '1234567890abcdef'
    encrypted_password  'password'

    after :create do |partner, evaluator|
      ns3 = 'ns3.domains.ph'
      ns4 = 'ns4.domains.ph'

      create :host, partner: partner, name: ns3 unless Host.exists?(name: ns3)
      create :host, partner: partner, name: ns4 unless Host.exists?(name: ns4)

      create :nameserver_configuration, partner: partner, value: ns3
      create :nameserver_configuration, partner: partner, value: ns4

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
        { partner: partner, action: 'domain_renew',   period: 1,  price: 32.money },
        { partner: partner, action: 'domain_renew',   period: 2,  price: 64.money },
        { partner: partner, action: 'transfer_domain',  period: 0,  price: 15.money },
      ].each do |params|
        partner.partner_pricings << (create :partner_pricing, params)
      end
    end
  end

  factory :other_partner, class: Partner, aliases: [:losing_partner] do
    initialize_with { Partner.find_by(name: 'other_partner') || new }

    name 'other_partner'
    organization 'Company'
    url 'http://alpha.ph'
    nature 'Alpha Business'
    representative 'Alpha Guy'
    position 'Position'
    street 'Alpha Street'
    city 'Alpha City'
    state 'Alpha State'
    postal_code '1234'
    country_code 'PH'
    voice '+63.1234567'
    fax '+63.1234567'
    email 'alpha@alpha.ph'
    salt  '1234567890abcdef'
    encrypted_password  'password'

    after :create do |partner|
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
        { partner: partner, action: 'domain_renew',   period: 1,  price: 32.money },
        { partner: partner, action: 'domain_renew',   period: 2,  price: 64.money },
        { partner: partner, action: 'transfer_domain',  period: 0,  price: 15.money },
      ].each do |params|
        partner.partner_pricings << (create :partner_pricing, params)
      end
    end
  end

  factory :admin_partner, class: Partner do
    name 'admin'
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
    voice '+63.21234567'
    fax '+63.21234567'
    email 'alpha@alpha.org'
    salt  '1234567890abcdef'
    encrypted_password  'password'

    admin true
  end
end

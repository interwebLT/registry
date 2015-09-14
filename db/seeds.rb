User.delete_all

Partner.delete_all

PartnerPricing.delete_all
PartnerConfiguration.delete_all

Product.delete_all
ObjectStatus.delete_all

ObjectActivity.delete_all

Domain.delete_all

HostAddress.delete_all
Host.delete_all

Contact.delete_all
ContactHistory.delete_all

Order.delete_all
OrderDetail.delete_all

Credit.delete_all

def create_user username, admin: false, staff: false
  User.create username: username,
              password: 'password',
              representative: 'Representative',
              organization: 'Company',
              position: 'Position',
              street: 'Street',
              city: 'City',
              state: 'State',
              postal_code: '1234',
              country_code: 'PH',
              nature: 'Nature',
              url: "#{username}.ph",
              email: "info@#{username}.ph",
              voice: '+63.21234567',
              admin: admin,
              staff: staff
end

def create_pricing partner, action, period, price
  PartnerPricing.create partner: partner,
                        action: action,
                        period: period,
                        price: price
end

def create_domain partner, contact, name, registered_at = Date.today
  create_register_domain_order partner, 2, name, contact.handle, registered_at

  domain = Domain.named(name)

  ['ns3.domains.ph', 'ns4.domains.ph'].each do |host|
    Host.create! partner: partner, name: host unless Host.exists? name: host

    create_domain_host domain: domain, host_name: host
  end

  domain
end

def create_register_domain_order partner, period, domain_name, registrant, registered_at
  params = {
    currency_code: 'USD',
    ordered_at: Time.current.iso8601,
    order_details: [
      {
        type: 'domain_create',
        domain: domain_name,
        authcode: 'ABC123',
        period: period,
        registrant_handle: registrant,
        registered_at: registered_at
      }
    ]
  }

  order = Order.build(params, partner)
  order.save!
  order.complete!
end

def create_replenish_credits_order partner, credits = 5000.00
  params = {
    currency_code: 'USD',
    ordered_at: Time.current.iso8601,
    order_details: [
      {
        type: 'credits',
        credits: 5000.00,
        remarks:  'Replenish Credits'
      }
    ]
  }

  create_order params, partner
end

def create_renew_domain_order partner, period, domain_name, renewed_at = Time.now
  params = {
    currency_code: 'USD',
    ordered_at: Time.current.iso8601,
    order_details: [
      {
        type: 'domain_renew',
        domain: domain_name,
        period: period,
        renewed_at: renewed_at
      }
    ]
  }

  create_order params, partner
end

def create_order params, partner
  order = Order.build(params, partner)
  order.save!
  order.complete!
end

def create_host partner:, name:
  Host.create partner: partner, name: name
end

def create_contact partner:, handle:
  Contact.create  partner: partner,
                  handle: handle,
                  name: handle
end

def create_complete_contact partner:, handle:
  Contact.create  partner: partner,
                  handle: handle,
                  name: "Contact #{handle}",
                  organization: "Organization #{handle}",
                  street: 'Street',
                  street2: 'Street 2',
                  street3: 'Street 3',
                  city: 'City',
                  state: 'State',
                  postal_code: '1234',
                  country_code: 'PH',
                  local_name: 'Local contact',
                  local_organization: 'Local organization',
                  local_street: 'Local street',
                  local_street2: 'Local street 2',
                  local_street3: 'Local street 3',
                  local_city: 'Local city',
                  local_state: 'Local state',
                  local_postal_code: 'Local postal code',
                  local_country_code: 'Local country code',
                  voice: '+63.21234567',
                  voice_ext: '1234',
                  fax: '+63.21234567',
                  fax_ext: '1235',
                  email: "#{handle}@contact.ph"
end

def create_domain_host domain:, host_name:
  domain.product.domain_hosts.create name: host_name
end

def create_partner_configuration partner:, config_name:, value:
  PartnerConfiguration.create partner: partner,
                              config_name: config_name,
                              value: value
end

def default_partner_nameservers(partner:)
  ['ns3.domains.ph', 'ns4.domains.ph']. each do |ns|
    create_host partner: partner, name: ns if Host.exists?(name: ns)

    create_partner_configuration partner: partner, config_name: 'nameserver', value: ns
  end
end

def create_partner name:, domain_count: 0, admin: false, staff: false
  user = create_user name, admin: admin, staff: staff
  partner = user.partner

  default_partner_nameservers partner: partner

  (1..10).each do |period|
    create_pricing partner, 'domain_create', period, (35 * period).money
  end

  create_replenish_credits_order partner

  contact = create_contact partner: partner, handle: name

  (1..domain_count).each do |i|
    domain_name = "#{name}_domain#{i}"

    create_domain partner, contact, "#{domain_name}.ph"
    create_domain partner, contact, "#{domain_name}.com.ph"
    create_domain partner, contact, "#{domain_name}.net.ph"
    create_domain partner, contact, "#{domain_name}.org.ph"

    if i == 1
      create_renew_domain_order partner, 1, "#{domain_name}.ph"
      create_renew_domain_order partner, 2, "#{domain_name}.com.ph"
      create_renew_domain_order partner, 5, "#{domain_name}.net.ph"
      create_renew_domain_order partner, 10, "#{domain_name}.org.ph"
    end
  end

  partner
end

create_partner name: 'sync',  admin: true
create_partner name: 'admin', admin: true
create_partner name: 'staff', domain_count: 4, staff: true

alpha = create_partner name: 'alpha', domain_count: 4

complete_contact  = create_complete_contact partner: alpha, handle: 'Complete'
complete_domain   = create_domain alpha, complete_contact, 'complete.ph'

complete_domain.admin_contact   = complete_contact
complete_domain.billing_contact = complete_contact
complete_domain.tech_contact    = complete_contact
complete_domain.save!

beta = create_partner name: 'beta', domain_count: 5

complete_contact_2 = create_complete_contact partner: beta, handle: 'Complete-2'
complete_domain_2 = create_domain beta, complete_contact, 'complete-2.ph'

complete_domain_2.admin_contact   = complete_contact_2
complete_domain_2.billing_contact = complete_contact_2
complete_domain_2.tech_contact    = complete_contact_2
complete_domain_2.save!

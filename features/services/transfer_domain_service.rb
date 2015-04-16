def transfer_domain
  json_request = {
    partner: OTHER_PARTNER,
    currency_code: 'USD',
    order_details: [
      {
        type: 'transfer_domain',
        domain: DOMAIN
      }
    ]
  }

  order = Order.build json_request, @current_partner
  order.save!
  order.complete!
end

def assert_domain_transferred
  saved_domain.partner.name.must_equal NON_ADMIN_PARTNER
end

def renew_domain partner: nil
  json_request = {
    currency_code: 'USD',
    ordered_at: REGISTERED_AT + 1,
    order_details: [
      type: 'domain_renew',
      domain: DOMAIN,
      period: 2
    ]
  }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = partner if partner
  json_request.delete(:partner) if partner == NO_PARTNER

  post orders_url, json_request
end

def reverse_renew_domain
  order_detail = OrderDetail::RenewDomain.last

  order_detail.order.reverse!
end

def assert_renew_domain_order_created
  order_must_be_created status: 'pending', type: OrderDetail::RenewDomain
end

def assert_renew_domain_fee_must_be_deducted
  credits = @current_partner.credits.last

  credits.wont_be_nil
  credits.activity_type.must_equal 'use'
  credits.credits.must_equal BigDecimal.new(-65)
end

def assert_domain_must_be_renewed
  new_expires_at = REGISTERED_AT + 2.year

  saved_domain.expires_at.must_equal new_expires_at
end

def assert_domain_must_no_longer_be_renewed
  saved_domain.expires_at.must_equal REGISTERED_AT
end

def assert_renew_domain_fee_must_be_added_back
  credits = @current_partner.credits.last

  credits.wont_be_nil
  credits.activity_type.must_equal 'use'
  credits.amount.must_equal 64.00.money
end

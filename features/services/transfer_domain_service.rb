def transfer_domain
  @old_handle = saved_domain.registrant_handle
  @transfer_contact = create :other_contact
  json_request = {
    partner: @current_partner.name,
    currency_code: 'USD',
    ordered_at: '2015-08-07T16:00:00Z',
    order_details: [
      {
        type: 'transfer_domain',
        domain: DOMAIN,
        registrant_handle: @transfer_contact.handle
      }
    ]
  }

  post orders_url, json_request
end

def assert_domain_transferred
  saved_domain.partner.name.must_equal NON_ADMIN_PARTNER
  saved_domain.registrant_handle.must_equal @transfer_contact.handle

  latest_activity = saved_domain.domain_activities.last
  latest_activity.must_be_kind_of ObjectActivity::Transfer
  latest_activity.losing_partner.name.must_equal OTHER_PARTNER
  latest_activity.registrant_handle.must_equal @old_handle
end

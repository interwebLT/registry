CONTACT_HANDLE = 'contact'
NEW_CONTACT_HANDLE = 'new_contact'
OTHER_CONTACT_HANDLE = 'other_contact'
BLANK_CONTACT_HANDLE = ''
NON_EXISTING_CONTACT_HANDLE = 'non_existing'

def contact_does_not_exist handle = CONTACT_HANDLE
  contact = Contact.find_by(handle: handle)
  contact.delete if contact
end

def contact_exists handle = CONTACT_HANDLE, under: nil
  contact_does_not_exist handle

  other_partner = under

  partner = other_partner ? Partner.find_by(name: under) : @current_partner

  create :contact, partner: partner, handle: handle
end

def other_contact_exists
  contact_exists OTHER_CONTACT_HANDLE
end

def create_contact with: { partner: nil, json_request: nil }
  params = with

  json_request ||= { handle: CONTACT_HANDLE }

  json_request[:partner] = NON_ADMIN_PARTNER if @current_user.admin?
  json_request[:partner] = params[:partner] if params[:partner]

  json_request = params[:json_request] if params[:json_request]

  post contacts_url, json_request
end

def update_contact with: { handle: nil, partner: nil }
  params = with

  json_request = {
    name: 'new_name',
    email: 'new_email@contact.ph',
    organization: 'new_organization',
    phone: 'new_phone',
    fax: 'new_fax',
    street: 'new_street',
    city: 'new_city',
    state: 'new_state',
    country_code: 'new_country',
    postal_code: 'new_postal_code'
  }

  json_request[:handle] = params[:handle] if params[:handle]
  json_request[:partner] = params[:partner] if params[:partner]

  patch contact_path(CONTACT_HANDLE), json_request
end

def assert_contact_created
  assert_response_status_must_be_created

  expected_response = {
    handle: CONTACT_HANDLE,
    name: nil,
    email: nil,
    organization: nil,
    phone: nil,
    fax: nil,
    street: nil,
    city: nil,
    state: nil,
    country_code: nil,
    postal_code: nil
  }

  json_response.must_equal expected_response

  Contact.find_by(handle: CONTACT_HANDLE).wont_be_nil
end

def assert_create_contact_history_created
  assert_contact_history_created
end

def assert_update_contact_history_created
  assert_contact_history_created count: 2
end

def assert_contact_history_created count: 1
  contact = Contact.find_by(handle: CONTACT_HANDLE)
  contact.contact_histories.count.must_equal count

  assert_contact_history contact.contact_histories.last, contact
end

def assert_contact_history contact_history, contact
  contact_history.handle.must_equal contact.handle
  contact_history.partner.must_equal contact.partner
  contact_history.name.must_equal contact.name
  contact_history.email.must_equal contact.email
  contact_history.organization.must_equal contact.organization
  contact_history.phone.must_equal contact.phone
  contact_history.fax.must_equal contact.fax
  contact_history.street.must_equal contact.street
  contact_history.city.must_equal contact.city
  contact_history.state.must_equal contact.state
  contact_history.country_code.must_equal contact.country_code
  contact_history.postal_code.must_equal contact.postal_code
end

def assert_contact_updated
  assert_response_status_must_be_ok

  expected_response = {
    handle: CONTACT_HANDLE,
    name: 'new_name',
    email: 'new_email@contact.ph',
    organization: 'new_organization',
    phone: 'new_phone',
    fax: 'new_fax',
    street: 'new_street',
    city: 'new_city',
    state: 'new_state',
    country_code: 'new_country',
    postal_code: 'new_postal_code'
  }

  json_response.must_equal expected_response
end

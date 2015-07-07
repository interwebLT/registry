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
    organization: 'new_organization',
    street: 'new_street',
    street2: 'new_street2',
    street3: 'new_street3',
    city: 'new_city',
    state: 'new_state',
    postal_code: 'new_postal_code',
    country_code: 'new_country',
    local_name: 'New local name',
    local_organization: 'New local organization',
    local_street: 'New local street',
    local_street2: 'New local street 2',
    local_street3: 'New local street 3',
    local_city: 'New local city',
    local_state: 'New local state',
    local_postal_code: 'New local postal code',
    local_country_code: 'New local country code',
    voice: 'new_phone',
    voice_ext: '1234',
    fax: 'new_fax',
    fax_ext: '1234',
    email: 'new_email@contact.ph',
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
    organization: nil,
    street: nil,
    street2: nil,
    street3: nil,
    city: nil,
    state: nil,
    postal_code: nil,
    country_code: nil,
    local_name: nil,
    local_organization: nil,
    local_street: nil,
    local_street2: nil,
    local_street3: nil,
    local_city: nil,
    local_state: nil,
    local_postal_code: nil,
    local_country_code: nil,
    voice: nil,
    voice_ext: nil,
    fax: nil,
    fax_ext: nil,
    email: nil,
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
  contact_history.organization.must_equal contact.organization
  contact_history.street.must_equal contact.street
  contact_history.street2.must_equal contact.street2
  contact_history.street3.must_equal contact.street3
  contact_history.city.must_equal contact.city
  contact_history.state.must_equal contact.state
  contact_history.postal_code.must_equal contact.postal_code
  contact_history.country_code.must_equal contact.country_code

  contact_history.local_name.must_equal contact.local_name
  contact_history.local_organization.must_equal contact.local_organization
  contact_history.local_street.must_equal contact.local_street
  contact_history.local_street2.must_equal contact.local_street2
  contact_history.local_street3.must_equal contact.local_street3
  contact_history.local_city.must_equal contact.local_city
  contact_history.local_state.must_equal contact.local_state
  contact_history.local_postal_code.must_equal contact.local_postal_code
  contact_history.local_country_code.must_equal contact.local_country_code

  contact_history.voice.must_equal contact.voice
  contact_history.voice_ext.must_equal contact.voice_ext
  contact_history.fax.must_equal contact.fax
  contact_history.fax_ext.must_equal contact.fax_ext
  contact_history.email.must_equal contact.email
end

def assert_contact_updated
  assert_response_status_must_be_ok

  expected_response = {
    handle: CONTACT_HANDLE,
    name: 'new_name',
    organization: 'new_organization',
    street: 'new_street',
    street2: 'new_street2',
    street3: 'new_street3',
    city: 'new_city',
    state: 'new_state',
    postal_code: 'new_postal_code',
    country_code: 'new_country',
    local_name: 'New local name',
    local_organization: 'New local organization',
    local_street: 'New local street',
    local_street2: 'New local street 2',
    local_street3: 'New local street 3',
    local_city: 'New local city',
    local_state: 'New local state',
    local_postal_code: 'New local postal code',
    local_country_code: 'New local country code',
    voice: 'new_phone',
    voice_ext: '1234',
    fax: 'new_fax',
    fax_ext: '1234',
    email: 'new_email@contact.ph'
  }

  json_response.must_equal expected_response
end

def assert_contacts_displayed
  assert_response_status_must_be_ok

  json_response.length.must_equal 2
  p json_response
  json_response.must_equal contacts_response
end

def view_contacts
  get contacts_path
end

def contacts_response
  [
    {:handle=>"contact", :name=>nil, :organization=>nil, :street=>nil, :street2=>nil, :street3=>nil, :city=>nil, :state=>nil, :postal_code=>nil, :country_code=>nil, :local_name=>nil, :local_organization=>nil, :local_street=>nil, :local_street2=>nil, :local_street3=>nil, :local_city=>nil, :local_state=>nil, :local_postal_code=>nil, :local_country_code=>nil, :voice=>nil, :voice_ext=>nil, :fax=>nil, :fax_ext=>nil, :email=>nil}, 
    {:handle=>"other_contact", :name=>nil, :organization=>nil, :street=>nil, :street2=>nil, :street3=>nil, :city=>nil, :state=>nil, :postal_code=>nil, :country_code=>nil, :local_name=>nil, :local_organization=>nil, :local_street=>nil, :local_street2=>nil, :local_street3=>nil, :local_city=>nil, :local_state=>nil, :local_postal_code=>nil, :local_country_code=>nil, :voice=>nil, :voice_ext=>nil, :fax=>nil, :fax_ext=>nil, :email=>nil}
  ]
end

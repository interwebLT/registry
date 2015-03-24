require 'test_helper'

describe ContactSerializer do
  subject { ContactSerializer.new(contact).serializable_hash }

  let(:contact) { build :contact }

  specify { subject[:handle].must_equal contact.handle }

  specify { subject[:name].must_equal contact.name }
  specify { subject[:organization].must_equal contact.organization }
  specify { subject[:street].must_equal contact.street }
  specify { subject[:street2].must_equal contact.street2 }
  specify { subject[:street3].must_equal contact.street3 }
  specify { subject[:city].must_equal contact.city }
  specify { subject[:state].must_equal contact.state }
  specify { subject[:postal_code].must_equal contact.postal_code }
  specify { subject[:country_code].must_equal contact.country_code }

  specify { subject[:local_name].must_equal contact.local_name }
  specify { subject[:local_organization].must_equal contact.local_organization }
  specify { subject[:local_street].must_equal contact.local_street }
  specify { subject[:local_street2].must_equal contact.local_street2 }
  specify { subject[:local_street3].must_equal contact.local_street3 }
  specify { subject[:local_city].must_equal contact.local_city }
  specify { subject[:local_state].must_equal contact.local_state }
  specify { subject[:local_postal_code].must_equal contact.local_postal_code }
  specify { subject[:local_country_code].must_equal contact.local_country_code }

  specify { subject[:voice].must_equal contact.voice }
  specify { subject[:voice_ext].must_equal contact.voice_ext }
  specify { subject[:fax].must_equal contact.fax }
  specify { subject[:fax_ext].must_equal contact.fax_ext }
  specify { subject[:email].must_equal contact.email }
end

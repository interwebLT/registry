require 'test_helper'

describe ContactSerializer do
  subject { ContactSerializer.new(contact).serializable_hash }

  let(:contact) { build :contact }

  specify { subject[:handle].must_equal contact.handle }
  specify { subject[:name].must_equal contact.name }
  specify { subject[:email].must_equal contact.email }
  specify { subject[:organization].must_equal contact.organization }
  specify { subject[:voice].must_equal contact.voice }
  specify { subject[:fax].must_equal contact.fax }
  specify { subject[:street].must_equal contact.street }
  specify { subject[:street2].must_equal contact.street }
  specify { subject[:street3].must_equal contact.street }
  specify { subject[:city].must_equal contact.city }
  specify { subject[:state].must_equal contact.state }
  specify { subject[:country_code].must_equal contact.country_code }
  specify { subject[:postal_code].must_equal contact.postal_code }
end

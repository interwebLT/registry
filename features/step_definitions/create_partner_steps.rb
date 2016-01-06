When /^I create a new partner$/ do
  Partner.create  name:           'alpha',
                  representative: 'Alpha Representative',
                  position:       'Representative',
                  organization:   'Alpha Organization',
                  nature:         'Technology',
                  url:            'www.alpha.org',
                  street:         'Street',
                  city:           'City',
                  state:          'State',
                  postal_code:    '',
                  country_code:   'PH',
                  email:          'alpha@alpha.org',
                  voice:          '+63.21234567'
end

Then /^partner must be created$/ do
  Partner.exists?(name: 'alpha').must_equal true
end

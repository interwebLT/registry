When /^I create a new partner$/ do
  stub_request(:post, SyncCreatePartnerJob::URL)
    .with(headers: default_headers, body: 'partners/post_request'.body)
    .to_return status: 201

  Partner.build name:               'alpha',
                epp_password:       'password',
                encrypted_password: 'password',
                salt:               '1234567890abcdef',
                representative:     'Alpha Representative',
                position:           'Representative',
                organization:       'Alpha Organization',
                nature:             'Technology',
                url:                'www.alpha.org',
                street:             'Street',
                city:               'City',
                state:              'State',
                postal_code:        '',
                country_code:       'PH',
                email:              'alpha@alpha.org',
                voice:              '+63.21234567'
end

Then /^partner must be created$/ do
  Partner.exists?(name: 'alpha').must_equal true
end

Then /^partner must be synced to other systems$/ do
  assert_requested :post, SyncCreatePartnerJob::URL, times: 1
end

def view_activities
  domain = create :domain
  create :update_activity, domain: domain

  get activities_path
end

def assert_activities_displayed
  assert_response_status_must_be_ok

  json_response.must_equal activities_response
end

private

def activities_response
  [
    {
      id: 1,
      type: 'update',
      activity_at: '2015-01-01T00:00:00Z',
      object: {
        id: 1,
        type: 'domain',
        name: 'domain.ph'
      },
      property_changed: 'registrant',
      old_value: 'old_registrant',
      new_value: 'new_registrant'
    },
    {
      id: 2,
      type: 'create',
      activity_at: '2015-01-01T00:00:00Z',
      object: {
        id: 2,
        type: 'domain',
        name: 'domain.ph'
      }
    }
  ]
end

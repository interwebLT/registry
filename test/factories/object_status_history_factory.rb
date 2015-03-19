FactoryGirl.define do
  factory :object_status_history do
    object_status
    ok                          true
    inactive                    false
    client_hold                 false
    client_delete_prohibited    false
    client_renew_prohibited     false
    client_transfer_prohibited  false
    client_update_prohibited    false
  end
end

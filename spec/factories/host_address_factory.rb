FactoryGirl.define do
  factory :host_address do
    host
    address '123.123.123.001'
    type 'v4'
    created_at Time.now
    updated_at Time.now
  end
end

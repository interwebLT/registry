FactoryGirl.define do
  factory :credit do
    partner
    order
    amount  1000.money
    activity_type 'topup'
  end
end

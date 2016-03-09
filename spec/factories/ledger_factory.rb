FactoryGirl.define do
  factory :ledger do
    credit
    order
    amount  1000.money
    activity_type 'topup'
  end
end

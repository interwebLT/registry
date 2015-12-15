FactoryGirl.define do
  factory :ledger do
    partner
    credit
    order
    amount  1000.money
    activity_type 'topup'
  end
end

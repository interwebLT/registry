FactoryGirl.define do
  factory :credit do
    partner
    order
    credits 1000
    activity_type 'topup'
  end
end

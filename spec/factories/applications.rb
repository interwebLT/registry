FactoryGirl.define do
  factory :application do
    partner
    token   '1234567890ABCDEF'
    client  'client'
  end
end

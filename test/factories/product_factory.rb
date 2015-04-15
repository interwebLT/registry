FactoryGirl.define do
  factory :product do
    product_type 'domain'

    factory :domain_product do
      domain
    end
  end
end

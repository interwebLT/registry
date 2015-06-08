FactoryGirl.define do
  factory :product do
    product_type 'domain'

    factory :domain_product do
      after :create do |product, evaluator|
        create :domain, product: product
      end
    end
  end
end

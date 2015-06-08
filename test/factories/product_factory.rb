FactoryGirl.define do
  factory :product do
    product_type 'domain'

    factory :domain_product do
      after :create do |product, evaluator|
        create :domain, product: product
      end
    end

    factory :deleted_domain_product do
      product_type  'deleted_domain'

      after :create do |product, evaluator|
        create :deleted_domain, product: product
      end
    end
  end
end

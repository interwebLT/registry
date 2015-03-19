FactoryGirl.define do
  factory :host do
    partner
    name 'ns5.domains.ph'
    created_at Time.now
    updated_at Time.now

    factory :host_with_addresses do
      after :create do |host, evaluator|
        create :host_address, host: host, address: '123.456.789.001'
        create :host_address, host: host, address: '123.456.789.002'
      end
    end
  end
end

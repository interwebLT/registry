FactoryGirl.define do
  factory :partner_configuration do
    config_name 'nameserver'
    value 'ns3.domains.ph'

    factory :nameserver_configuration do
      config_name 'nameserver'
      value 'ns3.domains.ph'
    end

    factory :credit_limit_configuration do
      config_name 'credit_limit'
      value '500'
    end
  end
end

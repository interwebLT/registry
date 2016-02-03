FactoryGirl.define do
  factory :partner_configuration do
    partner
    config_name 'nameserver'
    value 'ns3.domains.ph'

    factory :nameserver_configuration do
      config_name 'nameserver'
      value 'ns3.domains.ph'
    end
  end
end

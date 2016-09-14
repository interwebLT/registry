FactoryGirl.define do
  factory :powerdns_record, class: Powerdns::Record do
    id 1
    powerdns_domain_id 1
    name "sample.com"
    type "CNAME"
    prio 1
    content "sample.com"
    preferences {{
      "weight" => 70,
      "port" => 80,
      "srv_content" => "sample.com"
    }}
  end
end

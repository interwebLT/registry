FactoryGirl.define do
  factory :credit, aliases: [:replenish_credits] do
    partner
    type Credit::BankReplenish.name
    amount 150.money
    status Credit::COMPLETE_CREDIT
    credited_at '2015-02-27 14:30'.in_time_zone
    remarks 'Replenish Credit'
    
    factory :pending_replenish_credits do
      status Credit::PENDING_CREDIT
    end
  end
end

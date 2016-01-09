FactoryGirl.define do
  factory :authorization do
    factory :user_authorization, class: UserAuthorization do
      user
    end
  end
end

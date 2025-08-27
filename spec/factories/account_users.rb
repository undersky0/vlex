FactoryBot.define do
  factory :account_user do
    association :account
    association :user
    roles { ["user"] }

    trait :admin do
      roles { ["admin"] }
    end

    trait :manager do
      roles { ["manager"] }
    end
  end
end

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }

    trait :with_account do
      transient do
        account { nil }
        roles { ["user"] }
      end

      after(:create) do |user, evaluator|
        if evaluator.account
          create(:account_user, account: evaluator.account, user: user, roles: evaluator.roles)
        end
      end
    end

    trait :admin do
      with_account
      transient do
        roles { ["admin"] }
      end
    end
  end
end

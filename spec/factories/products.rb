FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:description) { |n| "Description for Product #{n}" }

    trait :with_subscription do
      transient do
        account { nil }
        license_count { 5 }
      end

      after(:create) do |product, evaluator|
        if evaluator.account
          create(:subscription,
                 product: product,
                 account: evaluator.account,
                 number_of_licenses: evaluator.license_count)
        end
      end
    end
  end
end

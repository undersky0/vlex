FactoryBot.define do
  factory :license_assignment do
    association :account
    association :user
    association :product

    # Ensure the user belongs to the account
    after(:build) do |license_assignment|
      unless license_assignment.account.account_users.exists?(user: license_assignment.user)
        create(:account_user, account: license_assignment.account, user: license_assignment.user, roles: ["user"])
      end

      # Ensure there's a subscription for the product in the account
      unless license_assignment.account.subscriptions.exists?(product: license_assignment.product)
        create(:subscription,
               account: license_assignment.account,
               product: license_assignment.product,
               number_of_licenses: 10)
      end
    end

    trait :with_subscription do
      after(:build) do |license_assignment|
        create(:subscription,
               account: license_assignment.account,
               product: license_assignment.product,
               number_of_licenses: 10)
      end
    end
  end
end

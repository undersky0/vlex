FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Account #{n}" }

    trait :with_users do
      after(:create) do |account|
        users = create_list(:user, 3)
        users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
      end
    end

    trait :with_products do
      after(:create) do |account|
        products = create_list(:product, 2)
        products.each do |product|
          create(:subscription, account: account, product: product)
        end
      end
    end
  end
end

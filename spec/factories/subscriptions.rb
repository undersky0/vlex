FactoryBot.define do
  factory :subscription do
    association :account
    association :product
    number_of_licenses { 5 }
    issued_at { 1.month.ago }
    expires_at { 1.year.from_now }

    trait :expired do
      issued_at { 2.years.ago }
      expires_at { 1.year.ago }
    end

    trait :with_many_licenses do
      number_of_licenses { 100 }
    end
  end
end

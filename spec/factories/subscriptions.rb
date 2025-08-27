FactoryBot.define do
  factory :subscription do
    id { 1 }
    account_id { 1 }
    product_id { 1 }
    number_of_licenses { 1 }
    issued_at { "2025-08-26 16:37:09" }
    expires_at { "2025-08-26 16:37:09" }
    created_at { "2025-08-26 16:37:09" }
    updated_at { "2025-08-26 16:37:09" }
  end
end

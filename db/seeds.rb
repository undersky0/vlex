# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Clear existing data (in development only)
if Rails.env.development?
  puts "🧹 Cleaning existing data..."
  LicenseAssignment.destroy_all
  Subscription.destroy_all
  AccountUser.destroy_all
  User.destroy_all
  Product.destroy_all
  Account.destroy_all
end

# Create Products
puts "📦 Creating products..."
products = [
  {
    name: "Microsoft Office 365",
    description: "Complete productivity suite with Word, Excel, PowerPoint, and Teams"
  },
  {
    name: "Adobe Creative Cloud",
    description: "Professional creative tools including Photoshop, Illustrator, and Premiere Pro"
  },
  {
    name: "Salesforce CRM",
    description: "Customer relationship management platform for sales and marketing teams"
  },
  {
    name: "Slack Business+",
    description: "Advanced team communication and collaboration platform"
  },
  {
    name: "Zoom Pro",
    description: "Professional video conferencing and webinar solution"
  },
  {
    name: "GitHub Enterprise",
    description: "Advanced code collaboration and version control for development teams"
  }
]

created_products = products.map do |product_data|
  Product.find_or_create_by!(name: product_data[:name]) do |product|
    product.description = product_data[:description]
  end
end

puts "✅ Created #{created_products.count} products"

# Create Accounts
puts "🏢 Creating accounts..."
accounts_data = [
  "TechCorp Solutions",
  "Creative Design Studio",
  "DataSync Analytics",
  "StartupHub Inc",
  "Global Marketing Group"
]

created_accounts = accounts_data.map do |account_name|
  Account.find_or_create_by!(name: account_name)
end

puts "✅ Created #{created_accounts.count} accounts"

# Create Users
puts "👥 Creating users..."
users_data = [
  { name: "Alice Johnson", email: "alice.johnson@techcorp.com" },
  { name: "Bob Smith", email: "bob.smith@techcorp.com" },
  { name: "Carol Williams", email: "carol.williams@creativestudio.com" },
  { name: "David Brown", email: "david.brown@creativestudio.com" },
  { name: "Eva Martinez", email: "eva.martinez@datasync.com" },
  { name: "Frank Wilson", email: "frank.wilson@datasync.com" },
  { name: "Grace Taylor", email: "grace.taylor@startuphub.com" },
  { name: "Henry Davis", email: "henry.davis@startuphub.com" },
  { name: "Iris Rodriguez", email: "iris.rodriguez@globalmarketing.com" },
  { name: "Jack Thompson", email: "jack.thompson@globalmarketing.com" },
  { name: "Karen Anderson", email: "karen.anderson@techcorp.com" },
  { name: "Liam Garcia", email: "liam.garcia@creativestudio.com" },
  { name: "Maya Singh", email: "maya.singh@datasync.com" },
  { name: "Noah Kim", email: "noah.kim@startuphub.com" },
  { name: "Olivia Chen", email: "olivia.chen@globalmarketing.com" }
]

created_users = users_data.map do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.name = user_data[:name]
  end
end

puts "✅ Created #{created_users.count} users"

# Create Account-User associations
puts "🔗 Creating account-user associations..."
account_user_associations = [
  # TechCorp Solutions
  [created_accounts[0], [created_users[0], created_users[1], created_users[10]]],
  # Creative Design Studio
  [created_accounts[1], [created_users[2], created_users[3], created_users[11]]],
  # DataSync Analytics
  [created_accounts[2], [created_users[4], created_users[5], created_users[12]]],
  # StartupHub Inc
  [created_accounts[3], [created_users[6], created_users[7], created_users[13]]],
  # Global Marketing Group
  [created_accounts[4], [created_users[8], created_users[9], created_users[14]]]
]

account_users_count = 0
account_user_associations.each do |account, users|
  users.each_with_index do |user, index|
    # Assign different roles: first user is admin, others are users
    role = index == 0 ? "admin" : "user"
    AccountUser.find_or_create_by!(account: account, user: user) do |account_user|
      account_user.roles = role
    end
    account_users_count += 1
  end
end

puts "✅ Created #{account_users_count} account-user associations"

# Create Subscriptions
puts "📋 Creating subscriptions..."
subscription_data = [
  # TechCorp Solutions subscriptions
  [created_accounts[0], created_products[0], 10, 1.year.ago, 1.year.from_now],    # Office 365
  [created_accounts[0], created_products[3], 5, 6.months.ago, 6.months.from_now], # Slack
  [created_accounts[0], created_products[5], 3, 3.months.ago, 9.months.from_now], # GitHub

  # Creative Design Studio subscriptions
  [created_accounts[1], created_products[1], 8, 2.months.ago, 10.months.from_now], # Adobe CC
  [created_accounts[1], created_products[3], 6, 1.month.ago, 11.months.from_now],  # Slack
  [created_accounts[1], created_products[4], 4, 2.weeks.ago, 50.weeks.from_now],   # Zoom

  # DataSync Analytics subscriptions
  [created_accounts[2], created_products[0], 12, 4.months.ago, 8.months.from_now], # Office 365
  [created_accounts[2], created_products[2], 6, 3.months.ago, 9.months.from_now],  # Salesforce
  [created_accounts[2], created_products[4], 8, 1.month.ago, 11.months.from_now],  # Zoom

  # StartupHub Inc subscriptions
  [created_accounts[3], created_products[0], 6, 1.month.ago, 11.months.from_now],  # Office 365
  [created_accounts[3], created_products[3], 4, 2.weeks.ago, 50.weeks.from_now],   # Slack
  [created_accounts[3], created_products[5], 5, 3.weeks.ago, 49.weeks.from_now],   # GitHub

  # Global Marketing Group subscriptions
  [created_accounts[4], created_products[0], 15, 2.months.ago, 10.months.from_now], # Office 365
  [created_accounts[4], created_products[2], 8, 1.month.ago, 11.months.from_now],   # Salesforce
  [created_accounts[4], created_products[4], 10, 3.weeks.ago, 49.weeks.from_now]    # Zoom
]

created_subscriptions = subscription_data.map do |account, product, licenses, issued_at, expires_at|
  Subscription.find_or_create_by!(account: account, product: product) do |subscription|
    subscription.number_of_licenses = licenses
    subscription.issued_at = issued_at
    subscription.expires_at = expires_at
  end
end

puts "✅ Created #{created_subscriptions.count} subscriptions"

# Create License Assignments
puts "🎫 Creating license assignments..."
license_assignments_data = [
  # TechCorp Solutions - Office 365 (3 out of 10)
  [created_accounts[0], created_users[0], created_products[0]],   # Alice
  [created_accounts[0], created_users[1], created_products[0]],   # Bob
  [created_accounts[0], created_users[10], created_products[0]],  # Karen

  # TechCorp Solutions - Slack (2 out of 5)
  [created_accounts[0], created_users[0], created_products[3]],   # Alice
  [created_accounts[0], created_users[1], created_products[3]],   # Bob

  # Creative Design Studio - Adobe CC (3 out of 8)
  [created_accounts[1], created_users[2], created_products[1]],   # Carol
  [created_accounts[1], created_users[3], created_products[1]],   # David
  [created_accounts[1], created_users[11], created_products[1]],  # Liam

  # Creative Design Studio - Slack (2 out of 6)
  [created_accounts[1], created_users[2], created_products[3]],   # Carol
  [created_accounts[1], created_users[3], created_products[3]],   # David

  # DataSync Analytics - Office 365 (3 out of 12)
  [created_accounts[2], created_users[4], created_products[0]],   # Eva
  [created_accounts[2], created_users[5], created_products[0]],   # Frank
  [created_accounts[2], created_users[12], created_products[0]],  # Maya

  # DataSync Analytics - Salesforce (2 out of 6)
  [created_accounts[2], created_users[4], created_products[2]],   # Eva
  [created_accounts[2], created_users[5], created_products[2]],   # Frank

  # StartupHub Inc - Office 365 (2 out of 6)
  [created_accounts[3], created_users[6], created_products[0]],   # Grace
  [created_accounts[3], created_users[7], created_products[0]],   # Henry

  # Global Marketing Group - Office 365 (3 out of 15)
  [created_accounts[4], created_users[8], created_products[0]],   # Iris
  [created_accounts[4], created_users[9], created_products[0]],   # Jack
  [created_accounts[4], created_users[14], created_products[0]]   # Olivia
]

created_license_assignments = license_assignments_data.map do |account, user, product|
  LicenseAssignment.find_or_create_by!(account: account, user: user, product: product)
end

puts "✅ Created #{created_license_assignments.count} license assignments"

puts ""
puts "🎉 Seeding completed successfully!"
puts ""
puts "📊 Summary:"
puts "  • #{Product.count} Products"
puts "  • #{Account.count} Accounts"
puts "  • #{User.count} Users"
puts "  • #{AccountUser.count} Account-User associations"
puts "  • #{Subscription.count} Subscriptions"
puts "  • #{LicenseAssignment.count} License Assignments"
puts ""
puts "🚀 You can now explore the application with realistic data!"

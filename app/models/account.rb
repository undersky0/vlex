class Account < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :subscriptions, dependent: :destroy
  has_many :license_assignments, dependent: :destroy
  has_many :products, through: :subscriptions

  validates :name, presence: true
end

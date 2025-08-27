class Product < ApplicationRecord
  has_many :subscriptions, dependent: :destroy
  has_many :license_assignments, dependent: :destroy
  has_many :accounts, through: :subscriptions
  has_many :users, through: :license_assignments

  validates :name, presence: true
  validates :description, presence: true
end

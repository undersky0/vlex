class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :account_id, uniqueness: { scope: :user_id, message: "User is already associated with this account" }
  validates :roles, presence: true
end

class AccountUser < ApplicationRecord
  belongs_to :account
  belongs_to :user

  validates :account_id, uniqueness: { scope: :user_id, message: "User is already associated with this account" }
  validates :roles, presence: true

  # Helper methods for role management
  def has_role?(role)
    roles.key?(role.to_s)
  end

  def add_role(role, permissions = true)
    self.roles = roles.merge(role.to_s => permissions)
    save
  end

  def remove_role(role)
    self.roles = roles.except(role.to_s)
    save
  end

  def role_list
    roles.keys
  end

  def admin?
    has_role?(:admin)
  end

  def member?
    has_role?(:member)
  end
end

class LicenseAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :account

  validates :user_id, uniqueness: {scope: [:account_id, :product_id],
                                   message: "User already has a license for this product in this account"}

  validate :user_belongs_to_account
  validate :account_has_subscription_for_product

  after_create_commit { broadcast_append_to(account, target: :license_assignments, partial: "license_assignments/license_assignment", locals: { license_assignment: self }) }
  after_destroy_commit { broadcast_remove_to(account, target: self) }

  private

  def user_belongs_to_account
    return unless user && account

    errors.add(:user, "must belong to the same account") unless account.users.include?(user)
  end

  def account_has_subscription_for_product
    return unless account && product

    subscription = account.subscriptions.find_by(product: product)
    errors.add(:product, "Account must have an active subscription for this product") unless subscription
  end
end

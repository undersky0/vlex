class Licenses::AssignmentValidator < ActiveInteraction::Base
  #TODO: should be with validators
  object :account
  object :user
  object :product

  def execute
    validate_subscription_for_product
    validate_user_not_already_assigned
    validate_licenses_available
  end

  def validate_subscription_for_product
    subscription = account.subscriptions.find_by(product: product)

    unless subscription
      errors.add(:account, "No subscription found for #{product.name}")
      return errors
    end
  end

  def validate_user_not_already_assigned
    if account.license_assignments.exists?(user: user, product: product)
      errors.add(:base, "#{user.name} already has a license for #{product.name}")
    end
  end

  def validate_licenses_available
    assigned_count = account.license_assignments.where(product: product).count
    subscription = account.subscriptions.find_by(product: product)

    return unless subscription # If no subscription, this will be caught by validate_subscription_for_product

    if assigned_count >= subscription.number_of_licenses
      errors.add(:base, "No available licenses for #{product.name}")
    end
  end
end

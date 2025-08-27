class Licenses::AssignmentService < ActiveInteraction::Base
  object :account, class: Account
  array :user_ids
  array :product_ids

  def execute
    license_assignment_ids = user_ids.product(product_ids)

    license_assignment_ids.each do |user_id, product_id|
      user = account.users.find_by(id: user_id)
      product = account.products.find_by(id: product_id)

      next unless user && product

      validator = Licenses::AssignmentValidator.run(
        account: account,
        user: user,
        product: product
      )

      if validator.errors.any?
        errors.merge!(validator.errors)
        next
      end

      # Create license assignment
      license_assignment = account.license_assignments.build(
        user: user,
        product: product
      )

      unless license_assignment.save
        errors.merge!("Failed to assign #{product.name} to #{user.name}: #{license_assignment.errors.full_messages.join(', ')}")
      end
    end
  end
end

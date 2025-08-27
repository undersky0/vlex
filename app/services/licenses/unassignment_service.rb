class Licenses::UnassignmentService < ActiveInteraction::Base
  object :account, class: Account
  array :user_ids
  array :product_ids

  def execute
    assignments_to_remove = []

    if user_ids.any? && product_ids.any?
      # User and product combinations provided
      license_assignment_ids = user_ids.product(product_ids)

      license_assignment_ids.each do |user_id, product_id|
        assignment = @account.license_assignments.find_by(
          user_id: user_id,
          product_id: product_id
        )
        assignments_to_remove << assignment if assignment
      end
    end

    if assignments_to_remove.empty?
      errors.add(:base, "Please select at least one license assignment to unassign.")
      return
    end

    assignments_to_remove.each(&:destroy)
  end
end

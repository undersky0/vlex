module Product::LicenseAssignments
  extend ActiveSupport::Concern

  included do
    has_many :license_assignments, dependent: :destroy
  end

  def license_availability_for(account)
    subscription = subscriptions.find_by(account: account)
    assigned_count = license_assignments.where(account: account).count
    total_licenses = subscription&.number_of_licenses || 0

    {
      total: total_licenses,
      assigned: assigned_count,
      available: total_licenses - assigned_count
    }
  end
end

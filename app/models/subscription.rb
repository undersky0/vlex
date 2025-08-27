class Subscription < ApplicationRecord
  belongs_to :account
  belongs_to :product

  validates :number_of_licenses, presence: true, numericality: {greater_than: 0}
  validates :issued_at, presence: true
  validates :expires_at, presence: true

  validate :expires_at_after_issued_at

  private

  def expires_at_after_issued_at
    return unless issued_at && expires_at

    errors.add(:expires_at, "must be after issued_at") if expires_at <= issued_at
  end
end

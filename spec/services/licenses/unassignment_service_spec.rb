require 'rails_helper'

RSpec.describe Licenses::UnassignmentService, type: :service do
  let(:account) { create(:account) }
  let(:users) { create_list(:user, 3) }
  let(:product) { create(:product) }
  let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 5) }

  before do
    users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
  end

  describe '#execute' do
    context 'with existing license assignments' do
      let!(:license_assignments) do
        users.map { |user| create(:license_assignment, account: account, user: user, product: product) }
      end
      let(:user_ids) { users.map(&:id) }
      let(:product_ids) { [product.id] }

      it 'removes license assignments successfully' do
        initial_count = LicenseAssignment.count

        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(LicenseAssignment.count).to eq(0)
        expect(initial_count - LicenseAssignment.count).to eq(3)
      end

      it 'removes only the specified assignments' do
        other_user = create(:user)
        create(:account_user, account: account, user: other_user, roles: ["user"])
        other_assignment = create(:license_assignment, account: account, user: other_user, product: product)

        result = described_class.run(
          account: account,
          user_ids: [users.first.id],
          product_ids: [product.id]
        )

        expect(result.valid?).to be true
        expect(LicenseAssignment.count).to eq(3) # 2 remaining from original users + 1 from other_user
        expect(LicenseAssignment.exists?(other_assignment.id)).to be true
      end
    end

    context 'with non-existent assignments' do
      let(:user_ids) { [users.first.id] }
      let(:product_ids) { [product.id] }

      it 'handles non-existent assignments gracefully' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.errors).to_not be_empty
        expect(result.errors[:base]).to include("Please select at least one license assignment to unassign.")
      end
    end

    context 'with partial matches' do
      let!(:existing_assignment) { create(:license_assignment, account: account, user: users.first, product: product) }
      let(:user_ids) { users.map(&:id) } # All users
      let(:product_ids) { [product.id] }

      it 'removes only existing assignments' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(LicenseAssignment.count).to eq(0)
      end
    end

    context 'with multiple products' do
      let(:products) { create_list(:product, 2) }
      let!(:assignments) do
        products.flat_map do |prod|
          create(:subscription, account: account, product: prod)
          users.map { |user| create(:license_assignment, account: account, user: user, product: prod) }
        end
      end
      let(:user_ids) { [users.first.id] }
      let(:product_ids) { products.map(&:id) }

      it 'removes assignments for all specified product-user combinations' do
        initial_count = LicenseAssignment.count

        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(LicenseAssignment.count).to eq(initial_count - 2) # 2 products for 1 user
      end
    end

    context 'with empty inputs' do
      let!(:license_assignment) { create(:license_assignment, account: account, user: users.first, product: product) }

      it 'handles empty user_ids' do
        result = described_class.run(
          account: account,
          user_ids: [],
          product_ids: [product.id]
        )

        expect(result.errors).to_not be_empty
        expect(result.errors[:base]).to include("Please select at least one license assignment to unassign.")
        expect(LicenseAssignment.count).to eq(1) # No changes
      end

      it 'handles empty product_ids' do
        result = described_class.run(
          account: account,
          user_ids: [users.first.id],
          product_ids: []
        )

        expect(result.errors).to_not be_empty
        expect(result.errors[:base]).to include("Please select at least one license assignment to unassign.")
        expect(LicenseAssignment.count).to eq(1) # No changes
      end
    end
  end

  describe 'error handling' do
    context 'with invalid account' do
      it 'is invalid with nil account' do
        result = described_class.run(
          account: nil,
          user_ids: [users.first.id],
          product_ids: [product.id]
        )

        expect(result.valid?).to be false
        expect(result.errors[:account]).to be_present
      end
    end
  end

  describe 'integration with assignment service' do
    let(:user_ids) { [users.first.id] }
    let(:product_ids) { [product.id] }

    it 'can unassign what was assigned' do
      # First assign
      assignment_result = Licenses::AssignmentService.run(
        account: account,
        user_ids: user_ids,
        product_ids: product_ids
      )

      expect(assignment_result.valid?).to be true
      expect(LicenseAssignment.count).to eq(1)

      # Then unassign
      unassignment_result = described_class.run(
        account: account,
        user_ids: user_ids,
        product_ids: product_ids
      )

      expect(unassignment_result.valid?).to be true
      expect(LicenseAssignment.count).to eq(0)
    end
  end
end

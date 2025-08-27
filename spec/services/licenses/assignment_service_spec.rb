require 'rails_helper'

RSpec.describe Licenses::AssignmentService, type: :service do
  let(:account) { create(:account) }
  let(:users) { create_list(:user, 3) }
  let(:product) { create(:product, :with_subscription, account: account, license_count: 5) }

  before do
    users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
  end

  describe '#execute' do
    context 'with valid inputs' do
      let(:user_ids) { users.map(&:id) }
      let(:product_ids) { [product.id] }

      it 'creates license assignments successfully' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(result.result.compact.size).to eq(3)
        expect(LicenseAssignment.count).to eq(3)
      end

      it 'assigns licenses to the correct users and products' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        license_assignments = result.result.compact

        license_assignments.each do |assignment|
          expect(assignment.account).to eq(account)
          expect(assignment.product).to eq(product)
          expect(users).to include(assignment.user)
        end
      end
    end

    context 'with invalid inputs' do
      let(:user_ids) { [999, 888] } # Non-existent user IDs
      let(:product_ids) { [product.id] }

      it 'handles non-existent users gracefully' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(result.result.compact).to be_empty
        expect(LicenseAssignment.count).to eq(0)
      end
    end

    context 'when exceeding license limits' do
      let(:product_with_limited_licenses) { create(:product, :with_subscription, account: account, license_count: 1) }
      let(:user_ids) { users.first(2).map(&:id) }
      let(:product_ids) { [product_with_limited_licenses.id] }

      it 'validates license availability' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.errors).to_not be_empty
        # Should only create one assignment due to license limit
        expect(result.result.compact.size).to be <= 1
      end
    end

    context 'with duplicate assignments' do
      let(:user_ids) { [users.first.id] }
      let(:product_ids) { [product.id] }

      before do
        create(:license_assignment, account: account, user: users.first, product: product)
      end

      it 'prevents duplicate license assignments' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.errors).to_not be_empty
        expect(LicenseAssignment.count).to eq(1) # Only the existing one
      end
    end

    context 'with multiple products' do
      let(:products) { create_list(:product, 2) }
      let(:user_ids) { [users.first.id] }
      let(:product_ids) { products.map(&:id) }

      before do
        products.each { |p| create(:subscription, account: account, product: p, number_of_licenses: 5) }
      end

      it 'creates assignments for all product-user combinations' do
        result = described_class.run(
          account: account,
          user_ids: user_ids,
          product_ids: product_ids
        )

        expect(result.valid?).to be true
        expect(result.result.compact.size).to eq(2) # 1 user × 2 products
        expect(LicenseAssignment.count).to eq(2)
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

    context 'with empty arrays' do
      it 'handles empty user_ids gracefully' do
        result = described_class.run(
          account: account,
          user_ids: [],
          product_ids: [product.id]
        )

        expect(result.valid?).to be true
        expect(result.result).to be_empty
      end

      it 'handles empty product_ids gracefully' do
        result = described_class.run(
          account: account,
          user_ids: [users.first.id],
          product_ids: []
        )

        expect(result.valid?).to be true
        expect(result.result).to be_empty
      end
    end
  end
end

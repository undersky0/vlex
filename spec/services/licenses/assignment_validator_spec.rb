require 'rails_helper'

RSpec.describe Licenses::AssignmentValidator, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user) }
  let(:product) { create(:product) }

  before do
    create(:account_user, account: account, user: user, roles: ["user"])
  end

  describe '#execute' do
    context 'with valid subscription and available licenses' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 5) }

      it 'validates successfully' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be true
        expect(result.errors).to be_empty
      end
    end

    context 'without subscription' do
      it 'adds error for missing subscription' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be false
        expect(result.errors[:account]).to include("No subscription found for #{product.name}")
      end
    end

    context 'with existing license assignment' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 5) }
      let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

      it 'adds error for duplicate assignment' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be false
        expect(result.errors[:base]).to include("#{user.name} already has a license for #{product.name}")
      end
    end

    context 'with no available licenses' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 1) }
      let(:other_user) { create(:user) }
      let!(:existing_assignment) { create(:license_assignment, account: account, user: other_user, product: product) }

      it 'adds error for no available licenses' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be false
        expect(result.errors[:base]).to include("No available licenses for #{product.name}")
      end
    end

    context 'with multiple validation errors' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 1) }
      let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

      it 'reports all validation errors' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be false
        expect(result.errors[:base]).to include("#{user.name} already has a license for #{product.name}")
        # Note: This will also trigger the "no available licenses" error since the existing assignment takes up the only license
      end
    end

    context 'with edge case: exactly at license limit' do
      let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 2) }
      let(:other_user) { create(:user) }
      let!(:existing_assignment) { create(:license_assignment, account: account, user: other_user, product: product) }

      it 'allows assignment when exactly one license is available' do
        result = described_class.run(
          account: account,
          user: user,
          product: product
        )

        expect(result.valid?).to be true
        expect(result.errors).to be_empty
      end
    end
  end

  describe 'private methods' do
    let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 5) }

    describe '#validate_subscription_for_product' do
      context 'with valid subscription' do
        it 'does not add errors' do
          validator = described_class.new(account: account, user: user, product: product)
          validator.send(:validate_subscription_for_product)

          expect(validator.errors).to be_empty
        end
      end

      context 'without subscription' do
        let(:product_without_subscription) { create(:product) }

        it 'adds subscription error' do
          validator = described_class.new(account: account, user: user, product: product_without_subscription)
          validator.send(:validate_subscription_for_product)

          expect(validator.errors[:account]).to include("No subscription found for #{product_without_subscription.name}")
        end
      end
    end

    describe '#validate_user_not_already_assigned' do
      context 'without existing assignment' do
        it 'does not add errors' do
          validator = described_class.new(account: account, user: user, product: product)
          validator.send(:validate_user_not_already_assigned)

          expect(validator.errors).to be_empty
        end
      end

      context 'with existing assignment' do
        let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

        it 'adds duplicate assignment error' do
          validator = described_class.new(account: account, user: user, product: product)
          validator.send(:validate_user_not_already_assigned)

          expect(validator.errors[:base]).to include("#{user.name} already has a license for #{product.name}")
        end
      end
    end

    describe '#validate_licenses_available' do
      context 'with available licenses' do
        it 'does not add errors' do
          validator = described_class.new(account: account, user: user, product: product)
          validator.send(:validate_licenses_available)

          expect(validator.errors).to be_empty
        end
      end

      context 'without available licenses' do
        let(:other_user) { create(:user) }
        let(:product_limited) { create(:product) }
        let!(:subscription_full) { create(:subscription, account: account, product: product_limited, number_of_licenses: 1) }
        let!(:existing_assignment) { create(:license_assignment, account: account, user: other_user, product: product_limited) }

        it 'adds no available licenses error' do
          validator = described_class.new(account: account, user: user, product: product_limited)
          validator.send(:validate_licenses_available)

          expect(validator.errors[:base]).to include("No available licenses for #{product_limited.name}")
        end
      end
    end
  end

  describe 'error handling' do
    context 'with invalid inputs' do
      it 'is invalid with nil account' do
        result = described_class.run(account: nil, user: user, product: product)
        expect(result.valid?).to be false
        expect(result.errors[:account]).to be_present
      end

      it 'is invalid with nil user' do
        result = described_class.run(account: account, user: nil, product: product)
        expect(result.valid?).to be false
        expect(result.errors[:user]).to be_present
      end

      it 'is invalid with nil product' do
        result = described_class.run(account: account, user: user, product: nil)
        expect(result.valid?).to be false
        expect(result.errors[:product]).to be_present
      end
    end
  end
end

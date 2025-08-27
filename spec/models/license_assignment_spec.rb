require "rails_helper"

RSpec.describe LicenseAssignment, type: :model do
  let(:account) { create(:account) }
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let!(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 10) }
  let(:license_assignment) { build(:license_assignment, account: account, user: user, product: product) }

  before do
    create(:account_user, account: account, user: user, roles: ["user"])
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(license_assignment).to be_valid
    end

    it 'requires an account' do
      license_assignment.account = nil
      expect(license_assignment).to_not be_valid
      expect(license_assignment.errors[:account]).to include("must exist")
    end

    it 'requires a user' do
      license_assignment.user = nil
      expect(license_assignment).to_not be_valid
      expect(license_assignment.errors[:user]).to include("must exist")
    end

    it 'requires a product' do
      license_assignment.product = nil
      expect(license_assignment).to_not be_valid
      expect(license_assignment.errors[:product]).to include("must exist")
    end

    context 'uniqueness validation' do
      let!(:existing_assignment) { create(:license_assignment, account: account, user: user, product: product) }

      it 'prevents duplicate assignments for the same account, user, and product' do
        duplicate_assignment = build(:license_assignment, account: account, user: user, product: product)

        expect(duplicate_assignment).to_not be_valid
        expect(duplicate_assignment.errors[:user_id]).to include("User already has a license for this product in this account")
      end

      it 'allows assignments for different users' do
        other_user = create(:user)
        create(:account_user, account: account, user: other_user, roles: ["user"])

        other_assignment = build(:license_assignment, account: account, user: other_user, product: product)

        expect(other_assignment).to be_valid
      end

      it 'allows assignments for different products' do
        other_product = create(:product)
        create(:subscription, account: account, product: other_product, number_of_licenses: 10)

        other_assignment = build(:license_assignment, account: account, user: user, product: other_product)

        expect(other_assignment).to be_valid
      end

      it 'allows assignments for different accounts' do
        other_account = create(:account)
        other_user = create(:user)
        create(:account_user, account: other_account, user: other_user, roles: ["user"])
        create(:subscription, account: other_account, product: product, number_of_licenses: 10)

        other_assignment = build(:license_assignment, account: other_account, user: other_user, product: product)

        expect(other_assignment).to be_valid
      end
    end
  end
end

require "rails_helper"

RSpec.describe Product, type: :model do
  let(:product) { build(:product) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(product).to be_valid
    end

    it 'requires a name' do
      product.name = nil
      expect(product).to_not be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'requires a description' do
      product.description = nil
      expect(product).to_not be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end
  end

  describe '#license_availability_for' do
    let!(:product) { create(:product) }
    let(:account) { create(:account) }

    context 'with subscription and no assignments' do
      let!(:subscription) { create(:subscription, product: product, account: account, number_of_licenses: 5) }

      it 'returns correct availability counts' do
        availability = product.license_availability_for(account)

        expect(availability[:total]).to eq(5)
        expect(availability[:assigned]).to eq(0)
        expect(availability[:available]).to eq(5)
      end
    end

    context 'with subscription and some assignments' do
      let!(:subscription) { create(:subscription, product: product, account: account, number_of_licenses: 5) }
      let(:users) { create_list(:user, 3) }
      let!(:assignments) do
        users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
        users.map { |user| create(:license_assignment, product: product, account: account, user: user) }
      end

      it 'returns correct availability counts' do
        availability = product.license_availability_for(account)

        expect(availability[:total]).to eq(5)
        expect(availability[:assigned]).to eq(3)
        expect(availability[:available]).to eq(2)
      end
    end

    context 'without subscription' do
      it 'returns zero availability' do
        availability = product.license_availability_for(account)

        expect(availability[:total]).to eq(0)
        expect(availability[:assigned]).to eq(0)
        expect(availability[:available]).to eq(0)
      end
    end

    context 'with fully allocated licenses' do
      let!(:subscription) { create(:subscription, product: product, account: account, number_of_licenses: 2) }
      let(:users) { create_list(:user, 2) }
      let!(:assignments) do
        users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
        users.map { |user| create(:license_assignment, product: product, account: account, user: user) }
      end

      it 'returns zero available licenses' do
        availability = product.license_availability_for(account)

        expect(availability[:total]).to eq(2)
        expect(availability[:assigned]).to eq(2)
        expect(availability[:available]).to eq(0)
      end
    end

    context 'with over-allocated licenses (edge case)' do
      let!(:subscription) { create(:subscription, product: product, account: account, number_of_licenses: 1) }
      let(:users) { create_list(:user, 2) }
      let!(:assignments) do
        users.each { |user| create(:account_user, account: account, user: user, roles: ["user"]) }
        # Manually create assignments that exceed the limit (simulating data inconsistency)
        users.map { |user| create(:license_assignment, product: product, account: account, user: user) }
      end

      it 'returns negative available count' do
        availability = product.license_availability_for(account)

        expect(availability[:total]).to eq(1)
        expect(availability[:assigned]).to eq(2)
        expect(availability[:available]).to eq(-1)
      end
    end
  end
end

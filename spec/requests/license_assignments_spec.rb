require 'rails_helper'

RSpec.describe "LicenseAssignments", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/license_assignments/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/license_assignments/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/license_assignments/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/license_assignments/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end

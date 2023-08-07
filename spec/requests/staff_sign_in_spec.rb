require "rails_helper"

RSpec.describe "Staff sign in", type: :request do
  before do
    FeatureFlags::FeatureFlag.activate(:service_open)
    FeatureFlags::FeatureFlag.activate(:sign_in_with_active_directory)
  end

  after do
    FeatureFlags::FeatureFlag.deactivate(:service_open)
    FeatureFlags::FeatureFlag.deactivate(:sign_in_with_active_directory)
  end

  shared_examples "an Azure login" do
    it "redirects to Azure login" do
      expect(response).to redirect_to("/staff/auth/azure_activedirectory_v2")
    end
  end

  describe "GET /assessor/applications" do
    before { get "/assessor/applications" }

    it_behaves_like "an Azure login"
  end

  describe "GET /support/countries" do
    before { get "/support/countries" }

    it_behaves_like "an Azure login"
  end
end

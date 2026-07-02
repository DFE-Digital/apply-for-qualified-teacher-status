# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /personas", type: :request do
  context "when hosting environment is production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s the personas list" do
      get personas_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
    end
  end

  context "when hosting environment is production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s the personas list" do
      get personas_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
    end
  end

  context "when hosting environment not production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "renders the personas page" do
      get personas_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Personas")
    end
  end

  context "when hosting environment not production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "Redirects to root path with warning message" do
      get personas_path

      expect(response).to redirect_to("/")
    end
  end
end

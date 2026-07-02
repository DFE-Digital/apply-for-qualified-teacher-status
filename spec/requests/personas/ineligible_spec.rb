# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /personas/ineligible", type: :request do
  context "when hosting environment is production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s" do
      post "/personas/ineligible"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
    end
  end

  context "when hosting environment is production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s" do
      post "/personas/ineligible"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
    end
  end

  context "when hosting environment not production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "redirects to result page" do
      post "/personas/ineligible"

      expect(response).to redirect_to("/eligibility/result")
    end
  end

  context "when hosting environment not production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "Redirects to root path with warning message" do
      post "/personas/ineligible"

      expect(response).to redirect_to("/")
    end
  end
end

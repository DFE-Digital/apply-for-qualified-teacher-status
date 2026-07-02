# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /personas/:staff_id/staff", type: :request do
  let(:staff) { create :staff }

  context "when hosting environment is production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s" do
      post "/personas/#{staff.id}/staff"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
      expect(controller.current_staff).to be_nil
    end
  end

  context "when hosting environment is production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(true)
    end

    it "404s" do
      post "/personas/#{staff.id}/staff"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
      expect(controller.current_staff).to be_nil
    end
  end

  context "when hosting environment not production and feature flag enabled" do
    before do
      FeatureFlags::FeatureFlag.activate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "redirects to assessor interface and signs user in" do
      post "/personas/#{staff.id}/staff"

      expect(response).to redirect_to("/assessor")
      expect(controller.current_staff).to eq(staff)
    end
  end

  context "when hosting environment not production and feature flag disabled" do
    before do
      FeatureFlags::FeatureFlag.deactivate(:personas)
      allow(HostingEnvironment).to receive(:production?).and_return(false)
    end

    it "Redirects to root path with warning message" do
      post "/personas/#{staff.id}/staff"

      expect(response).to redirect_to("/")
      expect(controller.current_staff).to be_nil
    end
  end
end

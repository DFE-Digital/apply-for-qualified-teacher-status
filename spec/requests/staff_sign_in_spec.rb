# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Staff sign in", type: :request do
  before { FeatureFlags::FeatureFlag.activate(:sign_in_with_active_directory) }

  after { FeatureFlags::FeatureFlag.deactivate(:sign_in_with_active_directory) }

  shared_examples "an Azure login" do
    it "redirects to Azure login" do
      expect(response).to redirect_to("/staff/auth/entra_id")
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

  describe "Removed staff devise routes" do
    removed_devise_paths = {
      "database authentication sign-in (new)" => [:get, "/staff/sign_in"],
      "database authentication sign-in (create)" => [:post, "/staff/sign_in"],
      "password reset (new)" => [:get, "/staff/password/new"],
      "password reset (update)" => [:put, "/staff/password"],
      "confirmation (new)" => [:get, "/staff/confirmation/new"],
      "confirmation (show)" => [:get, "/staff/confirmation"],
      "unlock (new)" => [:get, "/staff/unlock/new"],
      "unlock (show)" => [:get, "/staff/unlock"],
      "invitation accept (edit)" => [:get, "/staff/invitation/accept"],
      "invitation (update)" => [:put, "/staff/invitation"],
    }

    removed_devise_paths.each do |description, (method, path)|
      it "throws 404 for #{description}" do
        public_send(method, path)
        expect(response.status).to eq(404)
      end
    end
  end
end

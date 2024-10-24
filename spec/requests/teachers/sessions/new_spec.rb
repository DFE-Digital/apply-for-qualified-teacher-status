# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /teacher/sign_in", type: :request do
  subject(:sign_in) { get new_teacher_session_path }

  it "renders the sign in page" do
    sign_in

    expect(response.body).to include("Sign in")
  end

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it "redirects to the GOV.UK One Login flow" do
      sign_in

      expect(response).to redirect_to "/teacher/auth/gov_one"
    end
  end
end

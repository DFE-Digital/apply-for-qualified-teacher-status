# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /teacher/sign_up", type: :request do
  subject(:sign_up) { get new_teacher_registration_path }

  it "renders the sign up page" do
    sign_up

    expect(response.body).to include("Your email address")
  end

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it "redirects to the GOV.UK One Login flow" do
      sign_up

      expect(response).to redirect_to "/teacher/auth/gov_one"
    end
  end
end

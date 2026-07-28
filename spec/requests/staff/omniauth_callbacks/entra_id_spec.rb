# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Staff Entra ID sign-in", type: :request do
  let(:callback_path) { staff_entra_id_omniauth_callback_path }
  let(:signed_in_redirect_path) { "/assessor" }

  let(:email) { "member@staff.com" }
  let(:azure_ad_uid) { "uid-123456789" }

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      "uid" => azure_ad_uid,
      "info" => {
        "email" => email,
      },
    )
  end

  before { OmniAuth.config.mock_auth[:default] = omniauth_hash }

  context "when a staff record already matches the Azure uid" do
    let!(:staff) { create :staff, email:, azure_ad_uid: }

    it "signs in without relinking and confirms staff" do
      get callback_path

      expect(response).to redirect_to(signed_in_redirect_path)
      expect(staff.reload.azure_ad_uid).to eq(azure_ad_uid)
      expect(staff).to be_confirmed
      expect(controller.current_staff).to eq(staff)
    end
  end

  context "when no uid matches but the email matches an unlinked account" do
    let!(:staff) { create :staff, email:, azure_ad_uid: nil }

    it "signs in, links the uid and confirms staff" do
      get callback_path

      expect(response).to redirect_to(signed_in_redirect_path)
      expect(staff.reload.azure_ad_uid).to eq(azure_ad_uid)
      expect(staff).to be_confirmed
      expect(controller.current_staff).to eq(staff)
    end
  end

  context "when the email matches an account already linked to a different uid" do
    let!(:staff) { create :staff, email:, azure_ad_uid: "other-entra-uid" }

    it "refuses to relink, fails sign in and redirects" do
      get callback_path

      expect(flash[:alert]).to eq(
        "There was a problem signing you in. Please try again.",
      )
      expect(response).to redirect_to(root_path)

      expect(staff.reload.azure_ad_uid).to eq("other-entra-uid")
      expect(controller.current_staff).to be_nil
    end
  end

  context "when no staff matches by uid or email" do
    it "fails sign in and redirects" do
      get callback_path

      expect(flash[:alert]).to eq(
        "There was a problem signing you in. Please try again.",
      )
      expect(response).to redirect_to(root_path)

      expect(controller.current_staff).to be_nil
    end
  end

  context "when no auth uid is provided" do
    let!(:staff) { create :staff, email: }
    let(:azure_ad_uid) { nil }

    it "fails sign-in without updating accounts with nil uid" do
      get callback_path

      expect(flash[:alert]).to eq(
        "There was a problem signing you in. Please try again.",
      )
      expect(response).to redirect_to(root_path)
      expect(controller.current_staff).to be_nil

      expect(staff.reload.azure_ad_uid).to be_nil
    end
  end

  context "when authentication on Microsoft has failed" do
    let!(:staff) { create :staff, email: }
    let(:omniauth_hash) { :access_denied }

    it "fails sign-in" do
      get callback_path

      expect(response).to redirect_to(root_path)
      expect(controller.current_staff).to be_nil

      expect(staff.reload.azure_ad_uid).to be_nil
    end
  end
end

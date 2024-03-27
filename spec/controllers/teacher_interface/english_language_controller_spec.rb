# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageController, type: :controller do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET exemption/citizenship" do
    subject(:perform) do
      get :edit_exemption, params: { exemption_field: "citizenship" }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "POST exemption/citizenship" do
    subject(:perform) do
      post :update_exemption, params: { exemption_field: "citizenship" }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "GET exemption/qualification" do
    subject(:perform) do
      get :edit_exemption, params: { exemption_field: "qualification" }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "POST exemption/qualification" do
    subject(:perform) do
      post :update_exemption, params: { exemption_field: "qualification" }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "GET proof-method" do
    subject(:perform) { get :edit_proof_method }

    include_examples "redirect unless application form is draft"
  end

  describe "POST proof-method" do
    subject(:perform) { post :update_proof_method }

    include_examples "redirect unless application form is draft"
  end

  describe "GET provider" do
    subject(:perform) { get :edit_provider }

    include_examples "redirect unless application form is draft"
  end

  describe "POST provider" do
    subject(:perform) { post :update_provider }

    include_examples "redirect unless application form is draft"
  end

  describe "GET provider-reference" do
    subject(:perform) { get :edit_provider_reference }

    include_examples "redirect unless application form is draft"
  end

  describe "POST provider-reference" do
    subject(:perform) { post :update_provider_reference }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check" do
    subject(:perform) { get :check }

    include_examples "redirect unless application form is draft"
  end
end

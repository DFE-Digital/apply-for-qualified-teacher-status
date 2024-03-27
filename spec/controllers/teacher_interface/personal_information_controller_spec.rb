# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::PersonalInformationController,
               type: :controller do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET show" do
    subject(:perform) { get :show }

    include_examples "redirect unless application form is draft"
  end

  describe "GET name_and_date_of_birth" do
    subject(:perform) { get :name_and_date_of_birth }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH name_and_date_of_birth" do
    subject(:perform) { patch :name_and_date_of_birth }

    include_examples "redirect unless application form is draft"
  end

  describe "GET alternative_name" do
    subject(:perform) { get :name_and_date_of_birth }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH alternative_name" do
    subject(:perform) { patch :alternative_name }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check" do
    subject(:perform) { get :check }

    include_examples "redirect unless application form is draft"
  end
end

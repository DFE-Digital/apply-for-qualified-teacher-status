# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::QualificationsController, type: :controller do
  before { FeatureFlag.activate(:service_open) }

  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET index" do
    subject(:perform) { get :index }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check" do
    subject(:perform) { get :check }

    include_examples "redirect unless application form is draft"
  end

  describe "GET new" do
    subject(:perform) { get :new }

    include_examples "redirect unless application form is draft"
  end

  describe "POST create" do
    subject(:perform) { post :create }

    include_examples "redirect unless application form is draft"
  end

  describe "GET add_another" do
    subject(:perform) { get :add_another }

    include_examples "redirect unless application form is draft"
  end

  describe "POST add_another" do
    subject(:perform) { post :add_another }

    include_examples "redirect unless application form is draft"
  end

  describe "GET edit" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) { get :edit, params: { id: qualification.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) { patch :update, params: { id: qualification.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "GET part_of_university_degree" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) do
      get :edit_part_of_university_degree, params: { id: qualification.id }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH part_of_university_degree" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) do
      patch :update_part_of_university_degree, params: { id: qualification.id }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "GET delete" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) { get :delete, params: { id: qualification.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "DELETE destroy" do
    let(:qualification) { create(:qualification, application_form:) }

    subject(:perform) { delete :destroy, params: { id: qualification.id } }

    include_examples "redirect unless application form is draft"
  end
end

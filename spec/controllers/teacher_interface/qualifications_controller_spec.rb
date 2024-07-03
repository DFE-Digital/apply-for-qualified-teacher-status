# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::QualificationsController, type: :controller do
  let(:teacher) { create(:teacher) }
  let!(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET index" do
    subject(:perform) { get :index }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check_collection" do
    subject(:perform) { get :check_collection }

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

  describe "GET part_of_degree" do
    subject(:perform) { get :edit_part_of_degree }

    include_examples "redirect unless application form is draft"
  end

  describe "POST part_of_degree" do
    subject(:perform) { post :update_part_of_degree }

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
    subject(:perform) { get :edit, params: { id: qualification.id } }

    let(:qualification) { create(:qualification, application_form:) }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update" do
    subject(:perform) { patch :update, params: { id: qualification.id } }

    let(:qualification) { create(:qualification, application_form:) }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check_member" do
    subject(:perform) { get :check_member, params: { id: qualification.id } }

    let(:qualification) { create(:qualification, application_form:) }

    include_examples "redirect unless application form is draft"
  end

  describe "GET delete" do
    subject(:perform) { get :delete, params: { id: qualification.id } }

    let(:qualification) { create(:qualification, application_form:) }

    include_examples "redirect unless application form is draft"
  end

  describe "DELETE destroy" do
    subject(:perform) { delete :destroy, params: { id: qualification.id } }

    let(:qualification) { create(:qualification, application_form:) }

    include_examples "redirect unless application form is draft"
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoriesController, type: :controller do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

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

  describe "GET add_another" do
    subject(:perform) { get :add_another }

    include_examples "redirect unless application form is draft"
  end

  describe "POST add_another" do
    subject(:perform) { post :add_another }

    include_examples "redirect unless application form is draft"
  end

  describe "GET edit_school" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { get :edit_school, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update_school" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { patch :update_school, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "GET edit_contact" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { get :edit_contact, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update_contact" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { patch :update_contact, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "GET check_member" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { get :check_member, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "GET delete" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { get :delete, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "DELETE destroy" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { delete :destroy, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end
end

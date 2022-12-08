# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::WorkHistoriesController, type: :controller do
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

  describe "GET has_work_history" do
    subject(:perform) { get :edit_has_work_history }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH has_work_history" do
    subject(:perform) { patch :update_has_work_history }

    include_examples "redirect unless application form is draft"
  end

  describe "GET edit" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { get :edit, params: { id: work_history.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update" do
    let(:work_history) { create(:work_history, application_form:) }

    subject(:perform) { patch :update, params: { id: work_history.id } }

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

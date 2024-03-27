# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::DocumentsController, type: :controller do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET edit" do
    let(:document) { create(:document, documentable: application_form) }

    subject(:perform) { get :edit, params: { id: document.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update" do
    let(:document) { create(:document, documentable: application_form) }

    subject(:perform) { patch :update, params: { id: document.id } }

    include_examples "redirect unless application form is draft"
  end
end

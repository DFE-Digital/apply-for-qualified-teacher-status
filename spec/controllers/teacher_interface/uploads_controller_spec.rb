# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::UploadsController, type: :controller do
  before { FeatureFlags::FeatureFlag.activate(:service_open) }

  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET new" do
    let(:document) { create(:document, documentable: application_form) }

    subject(:perform) { get :new, params: { document_id: document.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "POST create" do
    let(:document) { create(:document, documentable: application_form) }

    subject(:perform) { post :create, params: { document_id: document.id } }

    include_examples "redirect unless application form is draft"
  end

  describe "GET delete" do
    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, document:) }

    subject(:perform) do
      get :delete, params: { document_id: document.id, id: upload.id }
    end

    include_examples "redirect unless application form is draft"
  end

  describe "DELETE destroy" do
    let(:document) { create(:document, documentable: application_form) }
    let(:upload) { create(:upload, document:) }

    subject(:perform) do
      get :delete, params: { document_id: document.id, id: upload.id }
    end

    include_examples "redirect unless application form is draft"
  end
end

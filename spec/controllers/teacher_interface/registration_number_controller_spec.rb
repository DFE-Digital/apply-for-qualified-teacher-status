# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::RegistrationNumberController,
               type: :controller do
  before { FeatureFlags::FeatureFlag.activate(:service_open) }

  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  before { sign_in teacher, scope: :teacher }

  describe "GET edit" do
    subject(:perform) { get :edit }

    include_examples "redirect unless application form is draft"
  end

  describe "PATCH update" do
    subject(:perform) { patch :update }

    include_examples "redirect unless application form is draft"
  end
end

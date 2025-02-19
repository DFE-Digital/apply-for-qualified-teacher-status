# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GET /teacher/english-language", type: :request do
  subject(:sign_up) do
    get teacher_interface_application_form_english_language_path
  end

  let(:application_form) { create :application_form }

  before { sign_in(application_form.teacher) }

  it "redirects to the citizenship exemption path" do
    sign_up

    expect(response).to redirect_to(
      exemption_teacher_interface_application_form_english_language_path(
        "citizenship",
      ),
    )
  end

  context "when the English language section is complete" do
    let(:application_form) do
      create :application_form, :with_english_language_provider
    end

    it "redirects to the check english language proficiency path" do
      sign_up

      expect(response).to redirect_to(
        check_teacher_interface_application_form_english_language_path,
      )
    end
  end
end

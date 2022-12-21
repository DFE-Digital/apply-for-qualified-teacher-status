# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageProviderReferenceForm,
               type: :model do
  let(:application_form) { create(:application_form) }

  subject(:form) { described_class.new(application_form:, reference:) }

  describe "validations" do
    let(:reference) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:reference) }
  end

  describe "#save" do
    let(:reference) { "reference" }

    subject(:save) { form.save(validate: true) }

    it "saves the application form" do
      expect { save }.to change(
        application_form,
        :english_language_provider_reference,
      ).to("reference")
    end
  end
end

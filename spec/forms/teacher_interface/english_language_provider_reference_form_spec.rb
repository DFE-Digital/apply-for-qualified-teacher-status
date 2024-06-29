# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageProviderReferenceForm,
               type: :model do
  subject(:form) { described_class.new(application_form:, reference:) }

  let(:application_form) { create(:application_form) }

  describe "validations" do
    let(:reference) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:reference) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:reference) { "reference" }

    it "saves the application form" do
      expect { save }.to change(
        application_form,
        :english_language_provider_reference,
      ).to("reference")
    end

    context "with an existing other provider" do
      let(:application_form) do
        create(:application_form, :with_english_language_other_provider)
      end

      it "clears the reference" do
        expect { save }.to change(
          application_form,
          :english_language_provider_other,
        ).to(false)
      end
    end
  end
end

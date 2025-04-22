# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageExemptionForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, exemption_field:, exempt:)
  end

  let(:application_form) { create(:application_form) }
  let(:exemption_field) { "citizenship" }

  describe "validations" do
    let(:exempt) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:exemption_field) }
    it { is_expected.to allow_values(true, false).for(:exempt) }
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:exempt) { "true" }

    it "saves the application forms english_language_citizenship_exempt" do
      expect { save }.to change(
        application_form,
        :english_language_citizenship_exempt,
      ).to(true)
    end

    context "when the exemption is for qualifications" do
      let(:exemption_field) { "qualification" }

      it "saves the application form english_language_qualification_exempt" do
        expect { save }.to change(
          application_form,
          :english_language_qualification_exempt,
        ).to(true)
      end
    end

    context "with an existing English language provider" do
      let(:application_form) do
        create(:application_form, :with_english_language_provider)
      end

      it "clears the provider" do
        expect { save }.to change(
          application_form,
          :english_language_provider,
        ).to(nil)
      end
    end

    context "with an existing ESOL document selected" do
      let(:application_form) do
        create(:application_form, :with_english_language_esol)
      end

      it "deletes the ESOL document" do
        expect { save }.to change(
          application_form.english_for_speakers_of_other_languages_document.uploads,
          :count,
        ).to(0)
        expect(application_form.english_language_proof_method).to be_nil
      end
    end
  end
end

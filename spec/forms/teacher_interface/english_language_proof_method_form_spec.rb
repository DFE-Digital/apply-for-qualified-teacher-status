# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::EnglishLanguageProofMethodForm, type: :model do
  subject(:form) { described_class.new(application_form:, proof_method:) }

  let(:application_form) { create(:application_form) }

  describe "validations" do
    let(:proof_method) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:proof_method) }

    it do
      expect(subject).to validate_inclusion_of(:proof_method).in_array(
        %w[medium_of_instruction provider],
      )
    end

    context "when the application form accepts reduced evidence" do
      let(:application_form) do
        create(:application_form, reduced_evidence_accepted: true)
      end

      it do
        expect(subject).to validate_inclusion_of(:proof_method).in_array(
          %w[medium_of_instruction provider esol],
        )
      end
    end
  end

  describe "#save" do
    subject(:save) { form.save(validate: true) }

    let(:proof_method) { "provider" }

    it "saves the application form" do
      expect { save }.to change(
        application_form,
        :english_language_proof_method_provider?,
      ).to(true)
    end

    context "with an existing English language medium of instruction" do
      let(:application_form) do
        create(:application_form, :with_english_language_medium_of_instruction)
      end

      it "clears the documents" do
        expect { save }.to change(
          application_form.english_language_medium_of_instruction_document.uploads,
          :count,
        ).to(0)
      end
    end

    context "with an existing English language ESOL" do
      let(:application_form) do
        create(:application_form, :with_english_language_esol)
      end

      it "clears the documents" do
        expect { save }.to change(
          application_form.english_for_speakers_of_other_languages_document.uploads,
          :count,
        ).to(0)
      end
    end

    context "with existing English language as provider and changing to ESOL" do
      let(:application_form) do
        create(
          :application_form,
          :with_english_language_proficiency_document,
          reduced_evidence_accepted: true,
        )
      end

      let(:proof_method) { "esol" }

      it "clears the documents" do
        expect { save }.to change(
          application_form.english_language_proficiency_document.uploads,
          :count,
        ).to(0)
      end

      it "updates all the provider fields to nil" do
        subject

        expect(application_form).to have_attributes(
          english_language_provider_id: nil,
          english_language_provider_other: false,
          english_language_provider_reference: "",
        )
      end
    end
  end
end

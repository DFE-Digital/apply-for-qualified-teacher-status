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

    it "saves the application form" do
      expect { save }.to change(
        application_form,
        :english_language_citizenship_exempt,
      ).to(true)
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
  end
end

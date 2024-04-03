# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::QualificationsForm, type: :model do
  let(:assessment_section) { create(:assessment_section, :qualifications) }
  let(:user) { create(:staff) }
  let(:attributes) { {} }

  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
    )
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:assessment) { assessment_section.assessment }
    let(:application_form) { assessment.application_form }

    let!(:english_language_section) do
      create(
        :assessment_section,
        :english_language_proficiency,
        assessment: assessment_section.assessment,
      )
    end

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes" do
      let(:attributes) do
        { passed: true, english_language_section_passed: true }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment_section.reload.passed).to be true
      end

      it "sets the passed attribute on the english language proficiency section" do
        application_form.update!(english_language_qualification_exempt: true)

        save # rubocop:disable Rails/SaveBang

        expect(english_language_section.reload.passed).to be true
      end

      it "ignores the passed attribute for the ELP section if exemption is by citizenship" do
        application_form.update!(english_language_citizenship_exempt: true)

        save # rubocop:disable Rails/SaveBang

        expect(english_language_section.reload.passed).to be_nil
      end
    end
  end
end

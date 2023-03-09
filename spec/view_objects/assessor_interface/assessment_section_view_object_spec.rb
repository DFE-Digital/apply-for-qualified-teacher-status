# frozen_string_literal: true

require "rails_helper"
RSpec.describe AssessorInterface::AssessmentSectionViewObject do
  subject(:view_object) { described_class.new(params:) }

  let(:assessment_section) do
    create(:assessment_section, :personal_information, assessment:)
  end
  let(:assessment) { create(:assessment, application_form:) }
  let(:region) { create(:region) }
  let(:application_form) { create(:application_form, region:) }

  let(:params) do
    {
      key: "personal_information",
      assessment_id: assessment.id,
      application_form_id: application_form.id,
    }
  end

  before { assessment_section }

  describe "assessment_section" do
    it "returns the correct assessment section" do
      expect(subject.assessment_section).to eq(assessment_section)
    end
  end

  describe "assessment" do
    it "returns the correct assessment" do
      expect(subject.assessment).to eq(assessment)
    end
  end

  describe "application_form" do
    it "returns the correct application_form" do
      expect(subject.application_form).to eq(application_form)
    end
  end

  describe "registration_number" do
    it "returns the correct registration_number" do
      expect(subject.registration_number).to eq(
        application_form.registration_number,
      )
    end
  end

  describe "notes_label_key_for" do
    subject { super().notes_label_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { FailureReasons::DECLINABLE.sample }

      it do
        is_expected.to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "there-once-was-a-cat-with-a-hungry-belly" }

      it do
        is_expected.to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        is_expected.to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "notes_hint_key_for" do
    subject { super().notes_hint_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { FailureReasons::DECLINABLE.sample }

      it do
        is_expected.to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "soon-may-the-kitty-man-come" }

      it do
        is_expected.to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        is_expected.to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "notes_placeholder_key_for" do
    subject { super().notes_placeholder_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { FailureReasons::DECLINABLE.sample }

      it do
        is_expected.to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "with-birds-and-mice-and-some-tasty-nums" }

      it do
        is_expected.to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        is_expected.to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "#render_form?" do
    subject(:render_form?) { view_object.render_form? }

    it { is_expected.to be true }

    context "with a requested professional standing request" do
      before { create(:professional_standing_request, :requested, assessment:) }

      it { is_expected.to be false }
    end
  end

  describe "#show_english_language_provider_details?" do
    let(:params) do
      {
        key:,
        assessment_id: assessment.id,
        application_form_id: application_form.id,
      }
    end

    subject(:show_english_language_provider_details?) do
      view_object.show_english_language_provider_details?
    end

    context "when the application EL proof method is 'provider'" do
      let(:key) { "english_language_proficiency" }
      let(:application_form) do
        create(:application_form, :with_english_language_provider)
      end
      let(:assessment_section) do
        create(:assessment_section, :english_language_proficiency, assessment:)
      end

      it { is_expected.to be true }
    end

    context "when the application EL proof method is not 'provider'" do
      let(:key) { "english_language_proficiency" }
      let(:application_form) do
        create(:application_form, :with_english_language_medium_of_instruction)
      end
      let(:assessment_section) do
        create(:assessment_section, :english_language_proficiency, assessment:)
      end

      it { is_expected.to be false }
    end

    context "when the section is not 'english_language_proficiency'" do
      let(:key) { "personal_information" }
      let(:assessment_section) do
        create(:assessment_section, :personal_information, assessment:)
      end

      it { is_expected.to be false }
    end
  end

  describe "#show_english_language_exemption_checkbox?" do
    let(:params) do
      {
        key:,
        assessment_id: assessment.id,
        application_form_id: application_form.id,
      }
    end

    subject(:show_english_language_exemption_checkbox?) do
      view_object.show_english_language_exemption_checkbox?
    end

    before { create(:assessment_section, :qualifications, assessment:) }

    context "when the section is personal information" do
      let(:key) { "personal_information" }

      context "with exemption by citizenship" do
        let(:application_form) do
          create(
            :application_form,
            :with_english_language_exemption_by_citizenship,
          )
        end

        it { is_expected.to be true }
      end

      context "with exemption by country of study" do
        let(:application_form) do
          create(
            :application_form,
            :with_english_language_exemption_by_qualification,
          )
        end

        it { is_expected.to be false }
      end
    end

    context "when the section is qualifications" do
      let(:key) { "qualifications" }

      context "with exemption by citizenship" do
        let(:application_form) do
          create(
            :application_form,
            :with_english_language_exemption_by_citizenship,
          )
        end

        it { is_expected.to be false }
      end

      context "with exemption by country of study" do
        let(:application_form) do
          create(
            :application_form,
            :with_english_language_exemption_by_qualification,
          )
        end

        it { is_expected.to be true }
      end
    end
  end
end

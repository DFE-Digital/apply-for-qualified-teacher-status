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
      id: assessment_section.id,
      assessment_id: assessment.id,
      application_form_reference: application_form.reference,
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
      let(:failure_reason) { FailureReasons::AGE_RANGE }

      it do
        expect(subject).to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a fraud failure reason" do
      let(:failure_reason) { FailureReasons::FRAUD }

      it do
        expect(subject).to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.fraud",
        )
      end
    end

    context "with a passport expired failure reason" do
      let(:failure_reason) { FailureReasons::PASSPORT_DOCUMENT_EXPIRED }

      it do
        expect(subject).to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.passport_expired",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "there-once-was-a-cat-with-a-hungry-belly" }

      it do
        expect(subject).to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        expect(subject).to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "notes_hint_key_for" do
    subject { super().notes_hint_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { FailureReasons::AGE_RANGE }

      it do
        expect(subject).to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a fraud failure reason" do
      let(:failure_reason) { FailureReasons::FRAUD }

      it do
        expect(subject).to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.fraud",
        )
      end
    end

    context "with a passport expired failure reason" do
      let(:failure_reason) { FailureReasons::PASSPORT_DOCUMENT_EXPIRED }

      it do
        expect(subject).to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.passport_expired",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "soon-may-the-kitty-man-come" }

      it do
        expect(subject).to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        expect(subject).to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "notes_placeholder_key_for" do
    subject { super().notes_placeholder_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { FailureReasons::AGE_RANGE }

      it do
        expect(subject).to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.decline",
        )
      end
    end

    context "with a passport expired failure reason" do
      let(:failure_reason) { FailureReasons::PASSPORT_DOCUMENT_EXPIRED }

      it do
        expect(subject).to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.passport_expired",
        )
      end
    end

    context "with a text failure reason" do
      let(:failure_reason) { "with-birds-and-mice-and-some-tasty-nums" }

      it do
        expect(subject).to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.text",
        )
      end
    end

    context "with a document failure reason" do
      let(:failure_reason) { "additional_degree_certificate_illegible" }

      it do
        expect(subject).to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes.document",
        )
      end
    end
  end

  describe "#show_form?" do
    subject(:show_form?) { view_object.show_form? }

    it { is_expected.to be true }

    context "when a preliminary check is required" do
      let(:application_form) do
        create(:application_form, :requires_preliminary_check, region:)
      end

      let!(:preliminary_assessment_section) do
        create(:assessment_section, :preliminary, assessment:)
      end

      it { is_expected.to be false }

      context "and preliminary check is complete" do
        before { preliminary_assessment_section.update!(passed: true) }

        it { is_expected.to be true }
      end
    end

    context "with a the professional standing section and a requested professional standing request" do
      let(:assessment_section) do
        create(:assessment_section, :professional_standing, assessment:)
      end

      before { create(:requested_professional_standing_request, assessment:) }

      it { is_expected.to be false }
    end
  end

  describe "#show_english_language_provider_details?" do
    subject(:show_english_language_provider_details?) do
      view_object.show_english_language_provider_details?
    end

    context "when the application EL proof method is 'provider'" do
      let(:application_form) do
        create(:application_form, :with_english_language_provider)
      end
      let(:assessment_section) do
        create(:assessment_section, :english_language_proficiency, assessment:)
      end

      it { is_expected.to be true }
    end

    context "when the application EL proof method is not 'provider'" do
      let(:application_form) do
        create(:application_form, :with_english_language_medium_of_instruction)
      end
      let(:assessment_section) do
        create(:assessment_section, :english_language_proficiency, assessment:)
      end

      it { is_expected.to be false }
    end

    context "when the section is not 'english_language_proficiency'" do
      let(:assessment_section) do
        create(:assessment_section, :personal_information, assessment:)
      end

      it { is_expected.to be false }
    end
  end

  describe "#show_english_language_exemption_checkbox?" do
    subject(:show_english_language_exemption_checkbox?) do
      view_object.show_english_language_exemption_checkbox?
    end

    context "when the section is personal information" do
      before { create(:assessment_section, :qualifications, assessment:) }

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
      let(:assessment_section) do
        create(:assessment_section, :qualifications, assessment:)
      end

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

  describe "#teacher_name_and_date_of_birth" do
    let(:application_form) do
      create(
        :application_form,
        given_names: "Janet Jane",
        family_name: "Jones",
        date_of_birth: "1980-01-01",
      )
    end

    it "returns the teacher's name and date of birth" do
      expect(view_object.teacher_name_and_date_of_birth).to eq(
        "Janet Jane Jones (1 January 1980)",
      )
    end
  end

  describe "#work_history_application_forms_contact_email_used_as_teacher" do
    subject(:work_history_application_forms_contact_email_used_as_teacher) do
      view_object.work_history_application_forms_contact_email_used_as_teacher
    end

    let(:assessment_section) do
      create(:assessment_section, :work_history, assessment:)
    end

    before do
      create(:work_history, application_form:, contact_email: "same@gmail.com")
    end

    context "without an application form with the same email" do
      before do
        create(
          :application_form,
          teacher: create(:teacher, email: "different@gmail.com"),
        )
      end

      it { is_expected.to eq({}) }
    end

    context "with an application form with the same email" do
      let!(:other_application_form) do
        create(
          :application_form,
          :submitted,
          teacher: create(:teacher, email: "same@gmail.com"),
        )
      end

      it { is_expected.to eq({ "same@gmail.com" => [other_application_form] }) }
    end
  end

  describe "#work_history_application_forms_contact_email_used_as_reference" do
    subject(:work_history_application_forms_contact_email_used_as_reference) do
      view_object.work_history_application_forms_contact_email_used_as_reference
    end

    let(:assessment_section) do
      create(:assessment_section, :work_history, assessment:)
    end
    let!(:other_application_form) { create(:application_form, :submitted) }

    before do
      create(:work_history, application_form:, contact_email: "same@gmail.com")
    end

    context "without an application form with the same email" do
      before do
        create(
          :work_history,
          application_form: other_application_form,
          contact_email: "different@gmail.com",
        )
      end

      it { is_expected.to eq({}) }
    end

    context "with an application form with the same email" do
      before do
        create(
          :work_history,
          application_form: other_application_form,
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.to eq({ "same@gmail.com" => [other_application_form] }) }
    end
  end
end

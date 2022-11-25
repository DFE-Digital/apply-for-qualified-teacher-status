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

  describe "qualifications" do
    it "returns an ordered list of qualifications" do
      expect(subject.qualifications).to match_array(
        application_form.qualifications.ordered,
      )
    end
  end

  describe "work_histories" do
    it "returns an ordered list of work histories" do
      expect(subject.work_histories).to match_array(
        application_form.work_histories.ordered,
      )
    end
  end

  describe "show_registration_number_summary" do
    subject { super().show_registration_number_summary }

    context "registration number is present" do
      before { application_form.update(registration_number: "1233445") }
      it { is_expected.to eq(true) }
    end

    context "registration number not present" do
      before { application_form.update(registration_number: nil) }
      it { is_expected.to eq(false) }
    end
  end

  describe "show_written_statement_summary" do
    subject { super().show_written_statement_summary }

    context "written statement is present" do
      let(:application_form) do
        create(:application_form, :with_written_statement)
      end
      it { is_expected.to eq(true) }
    end

    context "written statement is not present" do
      it { is_expected.to eq(false) }
    end
  end

  describe "notes_label_key_for" do
    subject { super().notes_label_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { AssessmentSection::DECLINE_FAILURE_REASONS.sample }

      it do
        is_expected.to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes_decline",
        )
      end
    end

    context "with a not decline failure reason" do
      let(:failure_reason) { "there-once-was-a-cat-with-a-hungry-belly" }

      it do
        is_expected.to eq(
          "helpers.label.assessor_interface_assessment_section_form.failure_reason_notes",
        )
      end
    end
  end

  describe "notes_hint_key_for" do
    subject { super().notes_hint_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { AssessmentSection::DECLINE_FAILURE_REASONS.sample }

      it do
        is_expected.to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes_decline",
        )
      end
    end

    context "with a not decline failure reason" do
      let(:failure_reason) { "soon-may-the-kitty-man-come" }

      it do
        is_expected.to eq(
          "helpers.hint.assessor_interface_assessment_section_form.failure_reason_notes",
        )
      end
    end
  end

  describe "notes_placeholder_key_for" do
    subject { super().notes_placeholder_key_for(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { AssessmentSection::DECLINE_FAILURE_REASONS.sample }

      it do
        is_expected.to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes_decline",
        )
      end
    end

    context "with a not decline failure reason" do
      let(:failure_reason) { "with-birds-and-mice-and-some-tasty-nums" }

      it do
        is_expected.to eq(
          "helpers.placeholder.assessor_interface_assessment_section_form.failure_reason_notes",
        )
      end
    end
  end

  describe "#show_online_checker?" do
    subject(:show_online_checker?) { view_object.show_online_checker? }

    it { is_expected.to be false }

    context "with a professional standing spoke" do
      before do
        params[:key] = "professional_standing"
        assessment_section.update!(key: "professional_standing")
      end

      it { is_expected.to be false }
    end

    context "with a registration number" do
      before { application_form.update!(registration_number: "abcdef") }

      it { is_expected.to be false }
    end

    context "with a checker URL" do
      before do
        region.country.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/checks",
        )
      end

      it { is_expected.to be false }
    end

    context "with a professional standing spoke and a registration number and a checker URL" do
      before do
        params[:key] = "professional_standing"
        assessment_section.update!(key: "professional_standing")

        application_form.update!(registration_number: "abcdef")

        region.country.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/checks",
        )
      end

      it { is_expected.to be true }
    end
  end

  describe "#online_checker_url" do
    subject(:online_checker_url) { view_object.online_checker_url }

    it { is_expected.to eq("") }

    context "with a country value set" do
      before do
        region.country.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/checks",
        )
      end

      it { is_expected.to eq("https://www.example.com/checks") }
    end

    context "with a region value set" do
      before do
        region.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/checks",
        )
      end

      it { is_expected.to eq("https://www.example.com/checks") }
    end

    context "with a country and a region value set" do
      before do
        region.country.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/country-checks",
        )
        region.update!(
          teaching_authority_online_checker_url:
            "https://www.example.com/region-checks",
        )
      end

      it { is_expected.to eq("https://www.example.com/region-checks") }
    end
  end

  describe "#professional_standing?" do
    subject(:professional_standing?) { view_object.professional_standing? }
    it { is_expected.to be false }
    context "with a professional standing spoke" do
      before do
        params[:key] = "professional_standing"
        assessment_section.update!(key: "professional_standing")
      end

      it { is_expected.to be true }
    end
  end
end

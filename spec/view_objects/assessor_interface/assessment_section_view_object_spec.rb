# frozen_string_literal: true

require "rails_helper"
RSpec.describe AssessorInterface::AssessmentSectionViewObject do
  subject { described_class.new(params:) }
  let(:assessment_section) do
    create(:assessment_section, :personal_information, assessment:)
  end
  let(:assessment) { create(:assessment, application_form:) }
  let(:application_form) { create(:application_form) }

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
end

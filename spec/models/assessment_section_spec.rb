# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_sections
#
#  id                       :bigint           not null, primary key
#  checks                   :string           default([]), is an Array
#  failure_reasons          :string           default([]), is an Array
#  key                      :string           not null
#  passed                   :boolean
#  selected_failure_reasons :jsonb            not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  assessment_id            :bigint           not null
#
# Indexes
#
#  index_assessment_sections_on_assessment_id          (assessment_id)
#  index_assessment_sections_on_assessment_id_and_key  (assessment_id,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
require "rails_helper"

RSpec.describe AssessmentSection, type: :model do
  subject(:assessment_section) { build(:assessment_section) }

  describe "validations" do
    it { is_expected.to belong_to(:assessment) }

    it { is_expected.to validate_presence_of(:key) }

    it do
      is_expected.to define_enum_for(:key).with_values(
        personal_information: "personal_information",
        qualifications: "qualifications",
        age_range_subjects: "age_range_subjects",
        work_history: "work_history",
        professional_standing: "professional_standing",
      ).backed_by_column_of_type(:string)
    end

    it { is_expected.to validate_absence_of(:selected_failure_reasons) }

    context "when not passed" do
      before { assessment_section.passed = false }

      it { is_expected.to validate_presence_of(:selected_failure_reasons) }
    end
  end

  describe "#state" do
    subject(:state) { assessment_section.state }

    context "with a passed assessment" do
      before { assessment_section.passed = true }
      it { is_expected.to eq(:completed) }
    end

    context "with a failed assessment" do
      before { assessment_section.passed = false }
      it { is_expected.to eq(:action_required) }
    end

    context "with no assessment yet" do
      before { assessment_section.passed = nil }
      it { is_expected.to eq(:not_started) }
    end
  end

  describe "#declines_assessment?" do
    subject(:declines_assessment?) { assessment_section.declines_assessment? }

    context "with a decline failure reason" do
      before do
        assessment_section.selected_failure_reasons = {
          duplicate_application: "Duplicate.",
        }
      end

      it { is_expected.to be true }
    end

    context "with no decline failure reasons" do
      before do
        assessment_section.selected_failure_reasons = {
          identification_document_expired: "Expired.",
        }
      end

      it { is_expected.to be false }
    end

    context "with no failure reasons" do
      it { is_expected.to be false }
    end
  end

  describe ".decline_failure_reason?" do
    subject { described_class.decline_failure_reason?(failure_reason:) }

    context "with a decline failure reason" do
      let(:failure_reason) { described_class::DECLINE_FAILURE_REASONS.sample }

      it { is_expected.to eq(true) }
    end

    context "with a non-decline failure reason" do
      let(:failure_reason) { :fitter_happier_more_productive }

      it { is_expected.to eq(false) }
    end
  end
end

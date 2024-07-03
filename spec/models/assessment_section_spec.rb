# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_sections
#
#  id              :bigint           not null, primary key
#  assessed_at     :datetime
#  checks          :string           default([]), is an Array
#  failure_reasons :string           default([]), is an Array
#  key             :string           not null
#  passed          :boolean
#  preliminary     :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assessment_id   :bigint           not null
#
# Indexes
#
#  index_assessment_sections_on_assessment_id                  (assessment_id)
#  index_assessment_sections_on_assessment_id_preliminary_key  (assessment_id,preliminary,key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#
require "rails_helper"

RSpec.describe AssessmentSection, type: :model do
  subject(:assessment_section) { create(:assessment_section) }

  describe "validations" do
    it { is_expected.to belong_to(:assessment) }

    it { is_expected.to validate_presence_of(:key) }

    it do
      expect(subject).to define_enum_for(:key).with_values(
        personal_information: "personal_information",
        qualifications: "qualifications",
        age_range_subjects: "age_range_subjects",
        english_language_proficiency: "english_language_proficiency",
        work_history: "work_history",
        professional_standing: "professional_standing",
      ).backed_by_column_of_type(:string)
    end

    context "when passed" do
      before do
        assessment_section.passed = true
        assessment_section.selected_failure_reasons << build(
          :selected_failure_reason,
        )
      end

      it "is expected to be invalid?" do
        assessment_section.valid?
        expect(assessment_section.errors[:selected_failure_reasons]).to eq(
          ["must be blank"],
        )
      end
    end

    context "when not passed" do
      before { assessment_section.passed = false }

      it { is_expected.to validate_presence_of(:selected_failure_reasons) }
    end
  end

  describe "#status" do
    subject(:status) { assessment_section.status }

    context "with a passed assessment" do
      before { assessment_section.passed = true }

      it { is_expected.to eq("accepted") }
    end

    context "with a failed assessment" do
      before { assessment_section.passed = false }

      it { is_expected.to eq("rejected") }
    end

    context "with no assessment yet" do
      before { assessment_section.passed = nil }

      it { is_expected.to eq("not_started") }
    end
  end

  describe "#declines_assessment?" do
    subject(:declines_assessment?) { assessment_section.declines_assessment? }

    context "with a decline failure reason" do
      before do
        create(:selected_failure_reason, :declinable, assessment_section:)
      end

      it { is_expected.to be true }
    end

    context "with no decline failure reasons" do
      before do
        create(
          :selected_failure_reason,
          :further_informationable,
          assessment_section:,
        )
      end

      it { is_expected.to be false }
    end

    context "with no failure reasons" do
      it { is_expected.to be false }
    end
  end
end

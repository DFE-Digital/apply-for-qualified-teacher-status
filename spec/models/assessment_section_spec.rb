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
#  selected_failure_reasons :string           default([]), is an Array
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
        work_history: "work_history",
        professional_standing: "professional_standing"
      ).backed_by_column_of_type(:string)
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
end

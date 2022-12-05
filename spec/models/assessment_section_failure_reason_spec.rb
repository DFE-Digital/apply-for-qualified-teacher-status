# frozen_string_literal: true

# == Schema Information
#
# Table name: assessment_section_failure_reasons
#
#  id                    :bigint           not null, primary key
#  assessor_feedback     :text
#  key                   :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  assessment_section_id :bigint           not null
#
# Indexes
#
#  index_as_failure_reason_assessment_section_id  (assessment_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#
require "rails_helper"

RSpec.describe AssessmentSectionFailureReason do
  describe "validations" do
    it { is_expected.to validate_presence_of(:key) }
    it do
      is_expected.to validate_inclusion_of(:key).in_array(FailureReasons::ALL)
    end
  end
end

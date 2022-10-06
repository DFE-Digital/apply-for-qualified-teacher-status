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
class AssessmentSection < ApplicationRecord
  belongs_to :assessment

  enum :key,
       {
         personal_information: "personal_information",
         qualifications: "qualifications",
         age_range_subjects: "age_range_subjects",
         work_history: "work_history",
         professional_standing: "professional_standing",
       }

  validates :key,
            presence: true,
            uniqueness: {
              scope: [:assessment],
            },
            inclusion: {
              in: keys.values,
            }

  validates :selected_failure_reasons,
            absence: true,
            if: -> { passed || passed.nil? }
  validates :selected_failure_reasons,
            presence: true,
            if: -> { passed == false }

  def state
    return :not_started if passed.nil?
    passed ? :completed : :action_required
  end

  DECLINE_FAILURE_REASONS = %w[
    duplicate_application
    applicant_already_qts
    teaching_qualifications_from_ineligible_country
    teaching_qualifications_not_at_required_level
    not_qualified_to_teach_mainstream
    teaching_hours_not_fulfilled
    authorisation_to_teach
    teaching_qualification
    confirm_age_range_subjects
    full_professional_status
  ].freeze

  def declines_assessment?
    DECLINE_FAILURE_REASONS.intersection(selected_failure_reasons.keys).present?
  end
end

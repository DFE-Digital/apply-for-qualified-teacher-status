# == Schema Information
#
# Table name: assessment_sections
#
#  id              :bigint           not null, primary key
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
class AssessmentSection < ApplicationRecord
  belongs_to :assessment
  has_many :selected_failure_reasons, dependent: :destroy

  enum :key,
       {
         personal_information: "personal_information",
         qualifications: "qualifications",
         age_range_subjects: "age_range_subjects",
         english_language_proficiency: "english_language_proficiency",
         work_history: "work_history",
         professional_standing: "professional_standing",
       }

  validates :key,
            presence: true,
            uniqueness: {
              scope: %i[assessment preliminary],
            },
            inclusion: {
              in: keys.values,
            }

  validates :preliminary, uniqueness: { scope: %i[assessment key] }

  scope :preliminary, -> { where(preliminary: true) }
  scope :not_preliminary, -> { where(preliminary: false) }

  validates :selected_failure_reasons,
            presence: true,
            if: -> { passed == false }
  validates :selected_failure_reasons,
            absence: true,
            if: -> { passed || passed.nil? }

  def declines_assessment?
    selected_failure_reasons.declinable.any?
  end

  def passed?
    passed == true
  end

  def failed?
    passed == false
  end

  def assessed?
    passed? || failed?
  end

  def status
    if passed?
      "accepted"
    elsif failed?
      "rejected"
    else
      "not_started"
    end
  end
end

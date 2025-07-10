# frozen_string_literal: true

# == Schema Information
#
# Table name: prioritisation_work_history_checks
#
#  id              :bigint           not null, primary key
#  checks          :string           default([]), is an Array
#  failure_reasons :string           default([]), is an Array
#  passed          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assessment_id   :bigint           not null
#  work_history_id :bigint           not null
#
# Indexes
#
#  index_prioritisation_work_history_checks_on_assessment_id    (assessment_id)
#  index_prioritisation_work_history_checks_on_work_history_id  (work_history_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_id => assessments.id)
#  fk_rails_...  (work_history_id => work_histories.id)
#
class PrioritisationWorkHistoryCheck < ApplicationRecord
  FAILURE_REASONS = [
    WORK_HISTORY_ROLE = "work_history_role",
    WORK_HISTORY_SETTING = "work_history_setting",
    WORK_HISTORY_IN_ENGLAND = "work_history_in_england",
    WORK_HISTORY_INSTITUTION_NOT_FOUND = "work_history_institution_not_found",
    WORK_HISTORY_REFERENCE_EMAIL = "work_history_reference_email",
    WORK_HISTORY_REFERENCE_JOB = "work_history_reference_job",
  ].freeze

  has_many :selected_prioritisation_failure_reasons, dependent: :destroy

  belongs_to :assessment
  belongs_to :work_history

  scope :passed, -> { where(passed: true) }

  def complete?
    !incomplete?
  end

  def incomplete?
    passed.nil?
  end
end

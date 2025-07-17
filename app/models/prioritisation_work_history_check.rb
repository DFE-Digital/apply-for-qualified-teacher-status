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
  has_many :selected_failure_reasons, dependent: :destroy

  belongs_to :assessment
  belongs_to :work_history

  scope :passed, -> { where(passed: true) }
  scope :not_passed, -> { where(passed: false) }

  def complete?
    !incomplete?
  end

  def incomplete?
    passed.nil?
  end

  def passed?
    passed == true
  end

  def failed?
    passed == false
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

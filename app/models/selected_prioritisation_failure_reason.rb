# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_prioritisation_failure_reasons
#
#  id                                   :bigint           not null, primary key
#  assessor_feedback                    :text
#  key                                  :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  prioritisation_work_history_check_id :bigint           not null
#
# Indexes
#
#  index_as_prioritisation_failure_reason_work_history_check_id  (prioritisation_work_history_check_id)
#
# Foreign Keys
#
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#
class SelectedPrioritisationFailureReason < ApplicationRecord
  belongs_to :prioritisation_work_history_check
  has_one :assessment, through: :prioritisation_work_history_check
  has_one :application_form, through: :assessment

  validates :key, presence: true
  validates :key,
            inclusion: {
              in: PrioritisationWorkHistoryCheck::FAILURE_REASONS,
            }
end

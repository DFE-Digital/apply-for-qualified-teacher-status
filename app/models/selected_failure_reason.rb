# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_failure_reasons
#
#  id                                   :bigint           not null, primary key
#  assessor_feedback                    :text
#  key                                  :string           not null
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  assessment_section_id                :bigint
#  prioritisation_work_history_check_id :bigint
#
# Indexes
#
#  index_as_failure_reason_assessment_section_id                 (assessment_section_id)
#  index_as_failure_reason_prioritisation_work_history_check_id  (prioritisation_work_history_check_id)
#
# Foreign Keys
#
#  fk_rails_...  (assessment_section_id => assessment_sections.id)
#  fk_rails_...  (prioritisation_work_history_check_id => prioritisation_work_history_checks.id)
#

class SelectedFailureReason < ApplicationRecord
  belongs_to :assessment_section, optional: true
  belongs_to :prioritisation_work_history_check, optional: true

  has_one :assessment, through: :assessment_section
  has_one :application_form, through: :assessment

  has_many :selected_failure_reasons_work_histories
  has_and_belongs_to_many :work_histories

  validates :key, presence: true
  validates :key, inclusion: { in: FailureReasons::ALL }

  scope :declinable, -> { where(key: FailureReasons::DECLINABLE) }
end

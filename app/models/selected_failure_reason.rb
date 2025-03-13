# frozen_string_literal: true

# == Schema Information
#
# Table name: selected_failure_reasons
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

class SelectedFailureReason < ApplicationRecord
  belongs_to :assessment_section
  has_one :assessment, through: :assessment_section
  has_one :application_form, through: :assessment

  validates :key, presence: true
  validates :key, inclusion: { in: FailureReasons::ALL }
  has_and_belongs_to_many :work_histories

  scope :declinable, -> { where(key: FailureReasons::DECLINABLE) }
end

# frozen_string_literal: true

class AssessorInterface::PrioritisationWorkHistoryCheckForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :prioritisation_work_history_check
  validates :prioritisation_work_history_check, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false if invalid?

    prioritisation_work_history_check.update!(passed:)
    update_assessment_started_at

    true
  end

  private

  def update_assessment_started_at
    assessment.update!(started_at: Time.zone.now) if assessment.started_at.nil?
  end

  delegate :assessment, to: :prioritisation_work_history_check
end

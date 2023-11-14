# frozen_string_literal: true

class AssessorInterface::SelectWorkHistoriesForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :application_form, :session
  validates :application_form, presence: true
  validates :session, exclusion: [nil]

  attribute :work_history_ids
  validates :work_history_ids,
            inclusion: {
              in: ->(form) do
                form
                  .application_form
                  &.work_histories
                  &.pluck(:id)
                  &.map(&:to_s) || []
              end,
            }
  validate :work_history_enough_months

  def save
    return false unless valid?
    session[:work_history_ids] = work_history_ids
    true
  end

  private

  def work_history_enough_months
    return if application_form.nil? || session.nil?

    if work_history_duration.count_months < 9
      errors.add(:work_history_ids, :blank)
    end
  end

  def work_history_duration
    WorkHistoryDuration.for_ids(work_history_ids, application_form:)
  end
end

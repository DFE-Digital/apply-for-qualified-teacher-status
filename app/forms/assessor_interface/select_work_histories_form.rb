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

    errors.add(:work_history_ids, :blank) unless has_enough_work_history?
  end

  def has_enough_work_history?
    WorkHistoryDuration.for_ids(
      work_history_ids,
      application_form:,
    ).enough_for_submission?
  end
end

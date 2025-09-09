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
                  &.teaching_role
                  &.pluck(:id)
                  &.map(&:to_s) || []
              end,
            }
  validate :work_history_enough_months_selected
  validate :work_history_most_recent_selected

  def save
    return false unless valid?
    session[:work_history_ids] = work_history_ids
    true
  end

  private

  def work_history_enough_months_selected
    return if application_form.nil? || session.nil?

    unless WorkHistoryDuration.for_ids(
             work_history_ids,
             application_form:,
           ).enough_for_submission?
      errors.add(:work_history_ids, :less_than_9_months)
    end
  end

  def work_history_most_recent_selected
    return if application_form.nil? || session.nil?
    return if application_form.region.checks_available?

    most_recent_work_history_id =
      application_form.work_histories.teaching_role.order_by_role.first.id.to_s

    unless work_history_ids.include?(most_recent_work_history_id)
      errors.add(:work_history_ids, :most_recent_not_selected)
    end
  end
end

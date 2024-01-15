# frozen_string_literal: true

class ReviewRequestable
  include ServicePattern

  def initialize(requestable:, user:, passed:, note:)
    @requestable = requestable
    @user = user
    @passed = passed
    @note = note
  end

  def call
    old_status = requestable.review_status

    ActiveRecord::Base.transaction do
      requestable.update!(
        review_passed: passed,
        review_note: note,
        reviewed_at: Time.zone.now,
      )

      requestable.after_reviewed(user:)
      application_form.reload

      create_timeline_event(old_status:)

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  private

  attr_reader :requestable, :user, :passed, :note

  def create_timeline_event(old_status:)
    CreateTimelineEvent.call(
      "requestable_reviewed",
      application_form:,
      user:,
      requestable:,
      old_value: old_status,
      new_value: requestable.review_status,
      note_text: note,
    )
  end

  delegate :application_form, to: :requestable
end

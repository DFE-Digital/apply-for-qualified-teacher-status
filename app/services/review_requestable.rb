# frozen_string_literal: true

class ReviewRequestable
  include ServicePattern

  def initialize(requestable:, user:, passed:, failure_assessor_note:)
    @requestable = requestable
    @user = user
    @passed = passed
    @failure_assessor_note = failure_assessor_note
  end

  def call
    ActiveRecord::Base.transaction do
      requestable.failure_assessor_note = failure_assessor_note
      requestable.reviewed!(passed)
      requestable.after_reviewed(user:)
      application_form.reload

      create_timeline_event

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  private

  attr_reader :requestable, :user, :passed, :failure_assessor_note

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: "requestable_reviewed",
      requestable:,
      application_form:,
    )
  end

  delegate :application_form, to: :requestable
end

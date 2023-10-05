# frozen_string_literal: true

class VerifyRequestable
  include ServicePattern

  def initialize(requestable:, user:, passed:, note:)
    @requestable = requestable
    @user = user
    @passed = passed
    @note = note
  end

  def call
    ActiveRecord::Base.transaction do
      requestable.update!(
        verify_passed: passed,
        verify_note: note,
        verified_at: Time.zone.now,
      )

      requestable.after_verified(user:)
      application_form.reload

      create_timeline_event

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  private

  attr_reader :requestable, :user, :passed, :note

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: "requestable_verified",
      requestable:,
      application_form:,
    )
  end

  delegate :application_form, to: :requestable
end

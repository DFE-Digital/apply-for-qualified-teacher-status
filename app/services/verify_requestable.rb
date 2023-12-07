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
    old_status = requestable.verify_status

    ActiveRecord::Base.transaction do
      requestable.update!(
        verify_passed: passed,
        verify_note: note,
        verified_at: Time.zone.now,
      )

      requestable.after_verified(user:)
      application_form.reload

      create_timeline_event(old_status:)

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  private

  attr_reader :requestable, :user, :passed, :note

  def create_timeline_event(old_status:)
    TimelineEvent.create!(
      creator: user,
      event_type: "requestable_verified",
      requestable:,
      application_form:,
      old_value: old_status,
      new_value: requestable.verify_status,
    )
  end

  delegate :application_form, to: :requestable
end

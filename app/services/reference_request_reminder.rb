# frozen_string_literal: true

class ReferenceRequestReminder
  include ServicePattern

  def initialize(reference_request:)
    @reference_request = reference_request
  end

  def call
    if send_reminder?
      send_email
      record_reminder
    end
  end

  private

  attr_reader :reference_request

  delegate :application_form, :assessment, :expired_at, to: :reference_request

  def send_reminder?
    four_weeks? || two_weeks?
  end

  def number_of_reminders_sent
    reference_request.reminder_emails.count
  end

  def days_until_expired
    today = Time.zone.today
    (expired_at.to_date - today).to_i
  end

  def four_weeks?
    days_until_expired <= 28 && number_of_reminders_sent.zero?
  end

  def two_weeks?
    days_until_expired <= 14 && number_of_reminders_sent.zero?
  end

  def send_email
    RefereeMailer
      .with(reference_request:, due_date: expired_at.to_date)
      .reference_reminder
      .deliver_later
  end

  def record_reminder
    reference_request.reminder_emails.create!
  end
end

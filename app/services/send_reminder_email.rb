# frozen_string_literal: true

class SendReminderEmail
  include ServicePattern

  def initialize(remindable:)
    @remindable = remindable
  end

  def call
    if send_reminder?
      send_email
      record_reminder
    end
  end

  private

  attr_reader :remindable

  def send_reminder?
    return false if remindable.try(:expired_at).present?
    return false unless remindable.expires_at

    remindable.should_send_reminder_email?(
      days_until_expired,
      number_of_reminders_sent,
    )
  end

  def number_of_reminders_sent
    remindable.reminder_emails.count
  end

  def days_until_expired
    today = Time.zone.today
    (remindable.expires_at.to_date - today).to_i
  end

  def send_email
    remindable.send_reminder_email(number_of_reminders_sent)
  end

  def record_reminder
    remindable.reminder_emails.create!
  end
end

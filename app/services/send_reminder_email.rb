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
    remindable.should_send_reminder_email?(number_of_reminders_sent)
  end

  def number_of_reminders_sent
    remindable.reminder_emails.count
  end

  def send_email
    remindable.send_reminder_email(number_of_reminders_sent)
  end

  def record_reminder
    remindable.reminder_emails.create!
  end
end

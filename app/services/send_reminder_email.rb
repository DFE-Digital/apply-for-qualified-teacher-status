# frozen_string_literal: true

class SendReminderEmail
  include ServicePattern

  def initialize(remindable:)
    @remindable = remindable
  end

  def call
    remindable.reminder_email_names.each do |name|
      if send_reminder?(name)
        send_email(name)
        record_reminder(name)
      end
    end
  end

  private

  attr_reader :remindable

  def send_reminder?(name)
    remindable.should_send_reminder_email?(name, number_of_reminders_sent(name))
  end

  def number_of_reminders_sent(name)
    remindable.reminder_emails.where(name:).count
  end

  def send_email(name)
    remindable.send_reminder_email(name, number_of_reminders_sent(name))
  end

  def record_reminder(name)
    remindable.reminder_emails.create!(name:)
  end
end

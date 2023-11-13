# frozen_string_literal: true

module Remindable
  extend ActiveSupport::Concern

  included { has_many :reminder_emails, as: :remindable }

  def should_send_reminder_email?(number_of_reminders_sent)
    # whether to send a reminder email at this point
  end

  def send_reminder_email(number_of_reminders_sent)
    # send a suitable reminder email for this object
  end
end

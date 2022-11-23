# frozen_string_literal: true
#
class FurtherInformationRequestReminder
  include ServicePattern
  include FurtherInformationRequestExpirable

  def initialize(further_information_request:)
    @further_information_request = further_information_request
  end

  def call
    further_information_request.reminder_emails.create! if send_reminder?
  end

  private

  attr_reader :further_information_request

  def send_reminder?
    two_weeks? || one_week? || two_days?
  end

  def number_of_reminders_sent
    further_information_request.reminder_emails.count
  end

  def two_weeks?
    days_until_expiry <= 14 && number_of_reminders_sent.zero?
  end

  def one_week?
    days_until_expiry <= 7 && number_of_reminders_sent == 1
  end

  def two_days?
    days_until_expiry <= 2 && number_of_reminders_sent == 2
  end
end

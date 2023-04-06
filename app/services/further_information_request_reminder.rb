# frozen_string_literal: true

class FurtherInformationRequestReminder
  include ServicePattern

  def initialize(further_information_request:)
    @further_information_request = further_information_request
  end

  def call
    if send_reminder?
      send_email
      record_reminder
    end
  end

  private

  attr_reader :further_information_request

  delegate :application_form,
           :assessment,
           :expired_at,
           to: :further_information_request
  delegate :teacher, to: :application_form

  def send_reminder?
    two_weeks? || one_week? || two_days?
  end

  def number_of_reminders_sent
    further_information_request.reminder_emails.count
  end

  def days_until_expired
    today = Time.zone.today
    (expired_at.to_date - today).to_i
  end

  def two_weeks?
    days_until_expired <= 14 && number_of_reminders_sent.zero?
  end

  def one_week?
    days_until_expired <= 7 && number_of_reminders_sent == 1
  end

  def two_days?
    days_until_expired <= 2 && number_of_reminders_sent == 2
  end

  def send_email
    TeacherMailer
      .with(
        teacher:,
        further_information_request:,
        due_date: expired_at.to_date,
      )
      .further_information_reminder
      .deliver_later
  end

  def record_reminder
    further_information_request.reminder_emails.create!
  end
end

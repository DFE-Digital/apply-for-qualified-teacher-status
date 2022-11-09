# frozen_string_literal: true

class TeacherMailerObserver
  def self.delivered_email(message)
    mailer_action_name = message.try(:mailer_action_name)
    application_form_id = message.try(:application_form_id)

    return if mailer_action_name.blank? || application_form_id.blank?

    TimelineEvent.create!(
      creator_name: "Mailer",
      event_type: "email_sent",
      application_form_id:,
      mailer_action_name:,
    )
  end
end

# frozen_string_literal: true

class ApplicationMailerObserver
  def self.delivered_email(message)
    mailer_action_name = message.try(:mailer_action_name)
    application_form_id = message.try(:application_form_id)
    message_subject = message.try(:subject)

    if mailer_action_name.blank? || application_form_id.blank? ||
         message_subject.blank?
      return
    end

    TimelineEvent.create!(
      creator_name: "Mailer",
      event_type: "email_sent",
      application_form_id:,
      mailer_action_name:,
      message_subject:,
    )
  end
end

ActionMailer::Base.register_observer(ApplicationMailerObserver)

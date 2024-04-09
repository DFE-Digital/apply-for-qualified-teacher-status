# frozen_string_literal: true

class DeliverEmail
  include ServicePattern

  def initialize(application_form:, mailer:, action:, **params)
    @application_form = application_form
    @mailer = mailer
    @action = action
    @params = params
  end

  def call
    create_job unless self.class.paused?
    create_timeline_event
  end

  def self.pause
    Rails.logger.info "Pausing email deliveries!"
    @paused = true
  end

  def self.continue
    Rails.logger.info "Continuing email deliveries!"
    @paused = false
  end

  def self.paused?
    @paused
  end

  private

  @paused = false

  attr_reader :application_form, :mailer, :action, :params

  def mail
    @mail ||= mailer.with(application_form:, **params).send(action)
  end

  def create_job
    mail.deliver_later
  end

  def create_timeline_event
    CreateTimelineEvent.call(
      "email_sent",
      application_form:,
      user: "Mailer",
      mailer_class_name: mailer.name.demodulize,
      mailer_action_name: action,
      message_subject: mail.subject,
    )
  end
end

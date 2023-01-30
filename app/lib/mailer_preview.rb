# frozen_string_literal: true

class MailerPreview
  class << self
    def with(mailer_class, **params)
      new(mailer_class:, params:)
    end
  end

  def initialize(mailer_class:, params:)
    @mailer_class = mailer_class
    @params = params
  end

  def respond_to_missing?(name)
    mailer.respond_to?(name)
  end

  def method_missing(name)
    mail = mailer.send(name)
    generate_preview(mail)
  end

  private

  attr_reader :mailer_class, :params

  def client
    @client ||= Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
  end

  def mailer
    @mailer ||= mailer_class.with(**params)
  end

  def generate_preview(mail)
    client.generate_template_preview(
      ApplicationMailer::GOVUK_NOTIFY_TEMPLATE_ID,
      personalisation: {
        to: mail.to.first,
        subject: mail.subject,
        body: mail.body.encoded,
      },
    ).html
  end
end

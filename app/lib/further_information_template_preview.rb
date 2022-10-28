class FurtherInformationTemplatePreview
  class << self
    def with(teacher:, **params)
      new(teacher:, params:)
    end
  end

  def initialize(teacher:, params:)
    @teacher = teacher
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

  attr_reader :teacher, :params

  def client
    @client ||= Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
  end

  def mailer
    @mailer ||= TeacherMailer.with(teacher:, **params)
  end

  def generate_preview(mail)
    client.generate_template_preview(
      TeacherMailer::GOVUK_NOTIFY_TEMPLATE_ID,
      personalisation: {
        to: mail.to.first,
        subject: mail.subject,
        body: mail.body.encoded,
      },
    ).html
  end
end

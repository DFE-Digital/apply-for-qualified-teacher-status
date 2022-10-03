class FurtherInformationTemplatePreview
  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_MAILER",
      "95adafaf-0920-4623-bddc-340853c047af",
    )

  class << self
    def with(teacher:, further_information_request:)
      new(teacher:, further_information_request:)
    end
  end

  def initialize(teacher:, further_information_request:)
    @teacher = teacher
    @further_information_request = further_information_request
  end

  def render
    client.generate_template_preview(
      GOVUK_NOTIFY_TEMPLATE_ID,
      personalisation: {
        to: mail.to.first,
        subject: mail.subject,
        body: mail.body.encoded,
      },
    ).html
  end

  private

  attr_reader :teacher, :further_information_request

  def client
    @client ||= Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
  end

  def mail
    TeacherMailer.with(
      teacher:,
      further_information_request:,
    ).further_information_requested
  end
end

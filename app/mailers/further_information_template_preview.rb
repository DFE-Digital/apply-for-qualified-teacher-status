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
        to:,
        subject:,
        body:,
      },
    ).html
  end

  private

  attr_reader :teacher, :further_information_request

  def to
    teacher.email
  end

  def subject
    I18n.t("mailer.further_information.required.subject")
  end

  def body
    further_information_request.email_content
  end

  def client
    @client ||= Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
  end
end

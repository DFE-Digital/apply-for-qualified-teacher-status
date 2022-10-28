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

  def render
    client.generate_template_preview(
      TeacherMailer::GOVUK_NOTIFY_TEMPLATE_ID,
      personalisation: {
        to: mail.to.first,
        subject: mail.subject,
        body: mail.body.encoded,
      },
    ).html
  end

  private

  attr_reader :teacher, :params

  def client
    @client ||= Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
  end

  def mail
    TeacherMailer.with(teacher:, **params).further_information_requested
  end
end

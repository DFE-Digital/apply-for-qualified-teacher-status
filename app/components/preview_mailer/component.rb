# frozen_string_literal: true

class PreviewMailer::Component < ViewComponent::Base
  def initialize(mailer_class:, name:, **params)
    super
    @mailer_class = mailer_class
    @name = name
    @params = params
  end

  def preview
    MailerPreview.with(mailer_class, **params).send(name)
  end

  attr_reader :mailer_class, :name, :params
end

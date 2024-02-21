# frozen_string_literal: true

class TeacherInterface::UploadForm < TeacherInterface::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include UploadableForm

  attr_accessor :document
  validates :document, presence: true

  delegate :application_form, to: :document

  attr_reader :timeout_error

  def save(validate:)
    super(validate:)
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Timeout::Error
    @timeout_error = true
    false
  end

  def update_model
    create_uploads!
  end
end

# frozen_string_literal: true

class RequestConsent
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    return unless consent_requests.exists?

    raise AlreadyRequested if consent_requests.requested.exists?

    create_and_request
    send_email
  end

  class AlreadyRequested < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
  delegate :consent_requests, to: :assessment

  def create_and_request
    ActiveRecord::Base.transaction do
      consent_requests.each do |requestable|
        RequestRequestable.call(requestable:, user:)
      end

      application_form.reload

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  def send_email
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :consent_requested,
    )
  end
end

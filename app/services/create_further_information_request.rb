# frozen_string_literal: true

class CreateFurtherInformationRequest
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    raise AlreadyExists if assessment.further_information_requests.exists?

    create_and_request
    send_email
  end

  class AlreadyExists < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment

  def create_and_request
    ActiveRecord::Base.transaction do
      requestable =
        FurtherInformationRequest.create!(
          assessment:,
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )

      RequestRequestable.call(requestable:, user:)

      application_form.reload

      ApplicationFormStatusUpdater.call(application_form:, user:)

      requestable
    end
  end

  def send_email
    TeacherMailer
      .with(application_form:)
      .further_information_requested
      .deliver_later
  end
end

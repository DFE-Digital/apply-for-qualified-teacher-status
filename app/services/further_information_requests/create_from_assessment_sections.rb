# frozen_string_literal: true

class FurtherInformationRequests::CreateFromAssessmentSections
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    raise AlreadyExists if assessment.further_information_requests.exists?

    create_and_request
  end

  class AlreadyExists < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment

  def create_and_request
    ActiveRecord::Base.transaction do
      assessment.request_further_information!

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
end

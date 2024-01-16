# frozen_string_literal: true

class CreateFurtherInformationRequest
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    further_information_request =
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

    TeacherMailer
      .with(application_form:)
      .further_information_requested
      .deliver_later

    further_information_request
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end

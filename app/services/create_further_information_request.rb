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
        ChangeApplicationFormState.call(
          application_form:,
          user:,
          new_state: :further_information_requested,
        )

        assessment.further_information_requests.create!(
          items:
            FurtherInformationRequestItemsFactory.call(
              assessment_sections: assessment.sections,
            ),
        )
      end

    TeacherMailer
      .with(teacher:, further_information_request:)
      .further_information_requested
      .deliver_later

    further_information_request
  end

  private

  attr_reader :assessment, :user

  def application_form
    @application_form ||= assessment.application_form
  end

  def teacher
    @teacher ||= application_form.teacher
  end
end

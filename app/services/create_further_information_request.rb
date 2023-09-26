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
        request =
          assessment.further_information_requests.create!(
            items:
              FurtherInformationRequestItemsFactory.call(
                assessment_sections: assessment.sections,
              ),
            requested_at: Time.zone.now,
          )

        ApplicationFormStatusUpdater.call(application_form:, user:)

        create_timeline_event(request)
        request.after_requested(user:)

        request
      end

    TeacherMailer.with(teacher:).further_information_requested.deliver_later

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

  def create_timeline_event(further_information_request)
    TimelineEvent.create!(
      application_form:,
      creator: user,
      event_type: "requestable_requested",
      requestable: further_information_request,
    )
  end
end

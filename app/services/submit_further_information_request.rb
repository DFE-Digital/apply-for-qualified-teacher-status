# frozen_string_literal: true

class SubmitFurtherInformationRequest
  include ServicePattern

  def initialize(further_information_request:, user:)
    @further_information_request = further_information_request
    @user = user
  end

  def call
    raise AlreadySubmitted if further_information_request.received?

    ActiveRecord::Base.transaction do
      further_information_request.received!

      create_timeline_event

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    TeacherMailer.with(teacher:).further_information_received.deliver_later
  end

  class AlreadySubmitted < StandardError
  end

  private

  attr_reader :further_information_request, :user

  def application_form
    @application_form ||=
      further_information_request.assessment.application_form
  end

  delegate :teacher, to: :application_form

  def create_timeline_event
    TimelineEvent.create!(
      application_form:,
      creator: user,
      event_type: "requestable_received",
      requestable: further_information_request,
    )
  end
end

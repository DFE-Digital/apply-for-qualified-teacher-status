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
      further_information_request.update!(
        state: "received",
        received_at: Time.zone.now,
      )

      ChangeApplicationFormState.call(
        application_form:,
        user:,
        new_state: :further_information_received,
      )
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
end

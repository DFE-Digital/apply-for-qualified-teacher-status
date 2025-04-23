# frozen_string_literal: true

class FurtherInformationRequests::CreateFromFurtherInformationReview
  include ServicePattern

  def initialize(further_information_request:, user:)
    @further_information_request = further_information_request
    @assessment = further_information_request.assessment
    @user = user
  end

  def call
    if assessment.further_information_requests.not_received.exists?
      raise AlreadyExists
    end

    send_email(create_and_request)
  end

  class AlreadyExists < StandardError
  end

  private

  attr_reader :assessment, :user, :further_information_request

  delegate :application_form, to: :assessment

  def create_and_request
    ActiveRecord::Base.transaction do
      assessment.request_further_information!

      requestable =
        FurtherInformationRequest.create!(
          assessment:,
          items: build_follow_up_items,
        )

      RequestRequestable.call(requestable:, user:)

      application_form.reload

      ApplicationFormStatusUpdater.call(application_form:, user:)

      requestable
    end
  end

  def send_email(further_information_request)
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :further_information_requested,
      further_information_request:,
    )
  end

  def build_follow_up_items
    further_information_request
      .items
      .review_decision_further_information
      .map do |follow_up_item|
      FurtherInformationRequestItem.new(
        information_type: follow_up_item.information_type,
        failure_reason_key: follow_up_item.failure_reason_key,
        failure_reason_assessor_feedback: follow_up_item.review_decision_note,
        document:
          (
            if follow_up_item.document.present?
              Document.new(document_type: follow_up_item.document.document_type)
            end
          ),
        work_history: follow_up_item.work_history,
      )
    end
  end
end

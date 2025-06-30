# frozen_string_literal: true

class RequestPrioritisationReferenceRequests
  include ServicePattern

  def initialize(assessment:, user:)
    @assessment = assessment
    @user = user
  end

  def call
    if assessment.prioritisation_reference_requests.present?
      raise AlreadyRequested
    end

    prioritisation_reference_requests =
      ActiveRecord::Base.transaction do
        prioritisation_reference_requests =
          assessment
            .prioritisation_work_history_checks
            .passed
            .map do |prioritisation_work_history_check|
            assessment.prioritisation_reference_requests.create!(
              prioritisation_work_history_check:,
              work_history: prioritisation_work_history_check.work_history,
            )
          end

        prioritisation_reference_requests.each do |requestable|
          RequestRequestable.call(requestable:, user:)
        end

        ApplicationFormStatusUpdater.call(application_form:, user:)

        prioritisation_reference_requests
      end

    if prioritisation_reference_requests.present?
      send_prioritisation_references_requested_email(
        prioritisation_reference_requests,
      )
    end
  end

  class AlreadyRequested < StandardError
  end

  private

  attr_reader :assessment, :user

  def send_prioritisation_references_requested_email(
    prioritisation_reference_requests
  )
    DeliverEmail.call(
      application_form:,
      mailer: TeacherMailer,
      action: :prioritisation_references_requested,
      prioritisation_reference_requests:,
    )
  end

  delegate :application_form, to: :assessment
end

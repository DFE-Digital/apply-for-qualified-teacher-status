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

    ActiveRecord::Base.transaction do
      assessment
        .prioritisation_work_history_checks
        .passed
        .each do |prioritisation_work_history_check|
        assessment
          .prioritisation_reference_requests
          .create!(
            prioritisation_work_history_check:,
            work_history: prioritisation_work_history_check.work_history,
          )
          .tap { |requestable| RequestRequestable.call(requestable:, user:) }
      end

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end
  end

  class AlreadyRequested < StandardError
  end

  private

  attr_reader :assessment, :user

  delegate :application_form, to: :assessment
end

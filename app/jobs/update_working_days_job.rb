# frozen_string_literal: true

class UpdateWorkingDaysJob < ApplicationJob
  def perform
    WorkingDays::UpdateApplicationsSinceSubmissionJob.perform_later
    WorkingDays::UpdateApplicationsSubmittedToCompletedJob.set(
      wait: 15.minutes,
    ).perform_later

    WorkingDays::UpdateAssessmentsSinceStartedJob.set(
      wait: 30.minutes,
    ).perform_later
    WorkingDays::UpdateAssessmentsStartedToCompletedJob.set(
      wait: 45.minutes,
    ).perform_later
    WorkingDays::UpdateAssessmentsSubmissionToStartedJob.set(
      wait: 60.minutes,
    ).perform_later
    WorkingDays::UpdateAssessmentsStartedToVerificationJob.set(
      wait: 75.minutes,
    ).perform_later
    WorkingDays::UpdateAssessmentsSubmissionToVerificationJob.set(
      wait: 90.minutes,
    ).perform_later
    WorkingDays::UpdateAssessmentsSubmissionToPrioritisationDecisionJob.set(
      wait: 105.minutes,
    ).perform_later

    WorkingDays::UpdateFurtherInformationRequestsAssessmentStartedToRequestedJob.set(
      wait: 120.minutes,
    ).perform_later
  end
end

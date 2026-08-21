# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkingDaysJob do
  subject(:perform) { described_class.perform_now }

  around { |example| freeze_time { example.run } }

  it "enqueues the applications-since-submission job immediately" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateApplicationsSinceSubmissionJob,
    )
  end

  it "enqueues the applications submitted-to-completed job after 15 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateApplicationsSubmittedToCompletedJob,
    ).at(15.minutes.from_now)
  end

  it "enqueues the assessments-since-started job after 30 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsSinceStartedJob,
    ).at(30.minutes.from_now)
  end

  it "enqueues the assessments started-to-completed job after 45 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsStartedToCompletedJob,
    ).at(45.minutes.from_now)
  end

  it "enqueues the assessments submission-to-started job after 60 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsSubmissionToStartedJob,
    ).at(60.minutes.from_now)
  end

  it "enqueues the assessments started-to-verification job after 75 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsStartedToVerificationJob,
    ).at(75.minutes.from_now)
  end

  it "enqueues the assessments submission-to-verification job after 90 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsSubmissionToVerificationJob,
    ).at(90.minutes.from_now)
  end

  it "enqueues the assessments submission-to-prioritisation-decision job after 105 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateAssessmentsSubmissionToPrioritisationDecisionJob,
    ).at(105.minutes.from_now)
  end

  it "enqueues the further-information-requests job after 120 minutes" do
    expect { perform }.to have_enqueued_job(
      WorkingDays::UpdateFurtherInformationRequestsAssessmentStartedToRequestedJob,
    ).at(120.minutes.from_now)
  end

  it "enqueues all nine working-days jobs" do
    expect { perform }.to have_enqueued_job.exactly(9).times
  end
end

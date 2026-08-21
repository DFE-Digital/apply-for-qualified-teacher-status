# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateAssessmentsStartedToCompletedJob,
               type: :job do
  describe "#perform" do
    subject(:perform) do
      travel_to(wednesday_today) { described_class.new.perform }
    end

    # Friday prior to a Monday bank holiday (2023-05-01) weekend
    let(:friday_previous) { Date.new(2023, 4, 28) }

    # Wednesday after a Monday bank holiday (2023-05-01) weekend
    let(:wednesday_today) { Date.new(2023, 5, 3) }
    let(:friday_application_form) do
      create(:application_form, :submitted, submitted_at: friday_previous)
    end

    let(:not_started_assessment) do
      create(:assessment, application_form: friday_application_form)
    end

    let(:started_incomplete_assessment) do
      create(
        :assessment,
        started_at: friday_previous,
        application_form: incomplete_application,
      )
    end
    let(:incomplete_application) do
      create(:application_form, :submitted, submitted_at: friday_previous)
    end

    let(:awarded_assessment) do
      create(
        :assessment,
        started_at: friday_previous,
        application_form: wednesday_application_form_awarded,
      )
    end
    let(:wednesday_application_form_awarded) do
      create(
        :application_form,
        :awarded,
        submitted_at: friday_previous,
        awarded_at: wednesday_today,
      )
    end

    let(:declined_assessment) do
      create(
        :assessment,
        started_at: friday_previous,
        application_form: wednesday_application_form_declined,
      )
    end
    let(:wednesday_application_form_declined) do
      create(
        :application_form,
        :declined,
        submitted_at: friday_previous,
        declined_at: wednesday_today,
      )
    end

    let(:withdrawn_assessment) do
      create(
        :assessment,
        started_at: friday_previous,
        application_form: wednesday_application_form_withdrawn,
      )
    end
    let(:wednesday_application_form_withdrawn) do
      create(
        :application_form,
        :withdrawn,
        submitted_at: friday_previous,
        withdrawn_at: wednesday_today,
      )
    end

    it "ignores not started assessment" do
      expect { perform }.not_to(
        change do
          not_started_assessment.reload.working_days_between_started_and_completed
        end,
      )
    end

    it "ignores not completed applications assessment that has started" do
      expect { perform }.not_to(
        change do
          started_incomplete_assessment.reload.working_days_between_started_and_completed
        end,
      )
    end

    it "sets the working days for awarded application" do
      expect { perform }.to change {
        awarded_assessment.reload.working_days_between_started_and_completed
      }.to(2)
    end

    it "sets the working days for declined application" do
      expect { perform }.to change {
        declined_assessment.reload.working_days_between_started_and_completed
      }.to(2)
    end

    it "sets the working days for withdrawn" do
      expect { perform }.to change {
        withdrawn_assessment.reload.working_days_between_started_and_completed
      }.to(2)
    end
  end
end

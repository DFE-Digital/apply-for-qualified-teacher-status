# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateAssessmentsSubmissionToPrioritisationDecisionJob,
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

    let(:assessment_without_prioritisation_flow) do
      create(:assessment, application_form: friday_application_form)
    end

    let(:wednesday_assessment_prioritised) do
      create(
        :assessment,
        started_at: wednesday_today,
        prioritisation_decision_at: wednesday_today,
        application_form: friday_application_form,
      )
    end

    it "ignores assessment without prioritisation flow" do
      expect { perform }.not_to(
        change do
          assessment_without_prioritisation_flow.reload.working_days_between_submitted_and_prioritisation_decision
        end,
      )
    end

    it "sets the working days for assessment that has prioritisation decision" do
      expect { perform }.to change {
        wednesday_assessment_prioritised.reload.working_days_between_submitted_and_prioritisation_decision
      }.to(2)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkingDays::UpdateAssessmentsSinceStartedJob, type: :job do
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

    let(:not_started_assessment) { create(:assessment) }

    let(:completed_application) { create :application_form, :awarded }
    let(:completed_assessment) do
      create(:assessment, application_form: completed_application)
    end

    let(:friday_assessment) { create(:assessment, started_at: friday_previous) }

    it "ignores not started assessments" do
      expect { perform }.not_to(
        change do
          not_started_assessment.reload.working_days_between_started_and_today
        end,
      )
    end

    it "ignores assessments with completed application form" do
      expect { perform }.not_to(
        change do
          completed_assessment.reload.working_days_between_started_and_today
        end,
      )
    end

    it "sets the working days" do
      expect { perform }.to change {
        friday_assessment.reload.working_days_between_started_and_today
      }.to(2)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkingDaysJob, type: :job do
  describe "#perform" do
    subject(:perform) do
      travel_to(tuesday_today) { described_class.new.perform }
    end

    let(:friday_previous) { Date.new(2022, 9, 30) }
    let(:tuesday_today) { Date.new(2022, 10, 4) }
    let(:friday_application_form) do
      create(:application_form, :submitted, submitted_at: friday_previous)
    end
    let(:not_recommended_assessment) { create(:assessment) }

    describe "application form working days since submission" do
      let(:draft_application_form) { create(:application_form) }
      let(:monday_application_form) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2022, 10, 3),
        )
      end

      it "ignores draft application forms" do
        expect { perform }.not_to(
          change do
            draft_application_form.reload.working_days_since_submission
          end,
        )
      end

      it "sets the working days for monday" do
        expect { perform }.to change {
          monday_application_form.reload.working_days_since_submission
        }.to(1)
      end

      it "sets the working days for friday" do
        expect { perform }.to change {
          friday_application_form.reload.working_days_since_submission
        }.to(2)
      end
    end

    describe "assessment working days since started" do
      let(:not_started_assessment) { create(:assessment) }
      let(:friday_assessment) do
        create(:assessment, started_at: friday_application_form.submitted_at)
      end

      it "ignores not started assessments" do
        expect { perform }.not_to(
          change { not_started_assessment.reload.working_days_since_started },
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          friday_assessment.reload.working_days_since_started
        }.to(2)
      end
    end

    describe "assessment working days started to recommendation" do
      let(:recommended_assessment) do
        create(
          :assessment,
          started_at: friday_application_form.submitted_at,
          recommended_at: tuesday_today,
        )
      end

      it "ignores not recommended assessments" do
        expect { perform }.not_to(
          change do
            not_recommended_assessment.reload.working_days_started_to_recommendation
          end,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          recommended_assessment.reload.working_days_started_to_recommendation
        }.to(2)
      end
    end

    describe "assessment working days submission to recommendation" do
      let(:recommended_assessment) do
        create(
          :assessment,
          application_form: friday_application_form,
          recommended_at: tuesday_today,
        )
      end

      it "ignores not recommended assessments" do
        expect { perform }.not_to(
          change do
            not_recommended_assessment.reload.working_days_submission_to_recommendation
          end,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          recommended_assessment.reload.working_days_submission_to_recommendation
        }.to(2)
      end
    end

    describe "assessment working days submission to started" do
      let(:recommended_assessment) do
        create(
          :assessment,
          application_form: friday_application_form,
          started_at: tuesday_today,
        )
      end

      it "ignores not recommended assessments" do
        expect { perform }.not_to(
          change do
            not_recommended_assessment.reload.working_days_submission_to_started
          end,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          recommended_assessment.reload.working_days_submission_to_started
        }.to(2)
      end
    end

    describe "further information request assessment started to creation" do
      let(:assessment) { create(:assessment, started_at: friday_previous) }
      let(:further_information_request) do
        create(
          :received_further_information_request,
          assessment:,
          created_at: tuesday_today,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          further_information_request.reload.working_days_assessment_started_to_creation
        }.to(2)
      end
    end

    describe "further information request days since received" do
      let(:requested_fi_request) { create(:further_information_request) }
      let(:received_fi_request) do
        create(
          :received_further_information_request,
          assessment: create(:assessment, recommended_at: tuesday_today),
          received_at: friday_application_form.submitted_at,
        )
      end

      it "ignores requested further information requests" do
        expect { perform }.not_to(
          change { requested_fi_request.reload.working_days_since_received },
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          received_fi_request.reload.working_days_since_received
        }.to(2)
      end
    end

    describe "further information request working days received to recommended" do
      let(:requested_fi_request) { create(:further_information_request) }
      let(:received_fi_request) do
        create(
          :received_further_information_request,
          assessment: create(:assessment, recommended_at: tuesday_today),
          received_at: friday_application_form.submitted_at,
        )
      end

      it "ignores not recommended assessments" do
        expect { perform }.not_to(
          change do
            requested_fi_request.reload.working_days_received_to_recommendation
          end,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          received_fi_request.reload.working_days_received_to_recommendation
        }.to(2)
      end
    end
  end
end

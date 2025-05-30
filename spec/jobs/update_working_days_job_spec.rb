# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateWorkingDaysJob, type: :job do
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

    describe "application form working days since submission" do
      let(:draft_application_form) { create(:application_form) }
      let(:tuesday_application_form) do
        create(
          :application_form,
          :submitted,
          submitted_at: Date.new(2023, 5, 2),
        )
      end

      it "ignores draft application forms" do
        expect { perform }.not_to(
          change do
            draft_application_form.reload.working_days_between_submitted_and_today
          end,
        )
      end

      it "sets the working days for monday" do
        expect { perform }.to change {
          tuesday_application_form.reload.working_days_between_submitted_and_today
        }.to(1)
      end

      it "sets the working days for friday" do
        expect { perform }.to change {
          friday_application_form.reload.working_days_between_submitted_and_today
        }.to(2)
      end
    end

    describe "application form working days from submitted to completed" do
      let(:draft_application_form) { create(:application_form) }
      let(:wednesday_application_form_awarded) do
        create(
          :application_form,
          :awarded,
          submitted_at: friday_previous,
          awarded_at: wednesday_today,
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
      let(:wednesday_application_form_withdrawn) do
        create(
          :application_form,
          :withdrawn,
          submitted_at: friday_previous,
          withdrawn_at: wednesday_today,
        )
      end

      it "ignores draft application forms" do
        expect { perform }.not_to(
          change do
            draft_application_form.reload.working_days_between_submitted_and_completed
          end,
        )
      end

      it "ignores submitted and not completed application forms" do
        expect { perform }.not_to(
          change do
            friday_application_form.reload.working_days_between_submitted_and_completed
          end,
        )
      end

      it "sets the working days for awarded" do
        expect { perform }.to change {
          wednesday_application_form_awarded.reload.working_days_between_submitted_and_completed
        }.to(2)
      end

      it "sets the working days for declined" do
        expect { perform }.to change {
          wednesday_application_form_declined.reload.working_days_between_submitted_and_completed
        }.to(2)
      end

      it "sets the working days for withdrawn" do
        expect { perform }.to change {
          wednesday_application_form_withdrawn.reload.working_days_between_submitted_and_completed
        }.to(2)
      end
    end

    describe "assessment working days since started" do
      let(:not_started_assessment) { create(:assessment) }
      let(:friday_assessment) do
        create(:assessment, started_at: friday_previous)
      end

      it "ignores not started assessments" do
        expect { perform }.not_to(
          change do
            not_started_assessment.reload.working_days_between_started_and_today
          end,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          friday_assessment.reload.working_days_between_started_and_today
        }.to(2)
      end
    end

    describe "assessment working days from assessment started to application form completed" do
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

    describe "assessment working days from application submitted to assessment started" do
      let(:not_started_assessment) do
        create(:assessment, application_form: friday_application_form)
      end

      let(:wednesday_started_assessment) do
        create(
          :assessment,
          started_at: wednesday_today,
          application_form: friday_application_form,
        )
      end
      let(:friday_application_form) do
        create(:application_form, submitted_at: friday_previous)
      end

      it "ignores not started assessment" do
        expect { perform }.not_to(
          change do
            not_started_assessment.reload.working_days_between_submitted_and_started
          end,
        )
      end

      it "sets the working days for started assessment" do
        expect { perform }.to change {
          wednesday_started_assessment.reload.working_days_between_submitted_and_started
        }.to(2)
      end
    end

    describe "assessment working days from application form submitted to assessment verification" do
      let(:not_started_assessment) do
        create(:assessment, application_form: friday_application_form)
      end

      let(:not_started_verification_assessment) do
        create(
          :assessment,
          application_form: application_form_not_verified,
          started_at: wednesday_today,
        )
      end
      let(:application_form_not_verified) do
        create(:application_form, submitted_at: friday_previous)
      end

      let(:wednesday_verification_started_assessment) do
        create(
          :assessment,
          started_at: wednesday_today,
          verification_started_at: wednesday_today,
          application_form: friday_application_form,
        )
      end
      let(:friday_application_form) do
        create(:application_form, submitted_at: friday_previous)
      end

      it "ignores not started assessment" do
        expect { perform }.not_to(
          change do
            not_started_assessment.reload.working_days_between_submitted_and_verification_started
          end,
        )
      end

      it "ignores not started verification assessment" do
        expect { perform }.not_to(
          change do
            not_started_verification_assessment.reload.working_days_between_submitted_and_verification_started
          end,
        )
      end

      it "sets the working days for started verification assessment" do
        expect { perform }.to change {
          wednesday_verification_started_assessment.reload.working_days_between_submitted_and_verification_started
        }.to(2)
      end
    end

    describe "assessment working days from application form started to verification" do
      let(:not_started_assessment) do
        create(:assessment, application_form: friday_application_form)
      end

      let(:not_started_verification_assessment) do
        create(:assessment, started_at: friday_previous)
      end

      let(:wednesday_verification_started_assessment) do
        create(
          :assessment,
          started_at: friday_previous,
          verification_started_at: wednesday_today,
        )
      end

      it "ignores not started assessment" do
        expect { perform }.not_to(
          change do
            not_started_assessment.reload.working_days_between_started_and_verification_started
          end,
        )
      end

      it "ignores not started verification assessment" do
        expect { perform }.not_to(
          change do
            not_started_verification_assessment.reload.working_days_between_started_and_verification_started
          end,
        )
      end

      it "sets the working days for started verification assessment" do
        expect { perform }.to change {
          wednesday_verification_started_assessment.reload.working_days_between_started_and_verification_started
        }.to(2)
      end
    end

    describe "further information request assessment started to requested" do
      let(:assessment) { create(:assessment, started_at: friday_previous) }
      let(:further_information_request) do
        create(
          :received_further_information_request,
          assessment:,
          requested_at: wednesday_today,
        )
      end

      it "sets the working days" do
        expect { perform }.to change {
          further_information_request.reload.working_days_between_assessment_started_to_requested
        }.to(2)
      end
    end
  end
end

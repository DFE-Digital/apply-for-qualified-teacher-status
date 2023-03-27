# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormStatusUpdater do
  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }

  shared_examples "changes status" do |new_status|
    it "changes the status to #{new_status}" do
      expect { call }.to change(application_form, :status).to(new_status)
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :state_changed,
        creator: user,
        application_form:,
        old_state: "draft",
        new_state: new_status,
      )
    end
  end

  describe "#call" do
    subject(:call) { described_class.call(application_form:, user:) }

    context "with a potential duplicate in DQT" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, :potential_duplicate, application_form:)
      end

      include_examples "changes status", "potential_duplicate_in_dqt"
    end

    context "with a declined_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          declined_at: Time.zone.now,
        )
      end

      include_examples "changes status", "declined"
    end

    context "with an awarded_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          awarded_at: Time.zone.now,
        )
      end

      include_examples "changes status", "awarded"
    end

    context "with a DQT TRN request" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, application_form:)
      end

      include_examples "changes status", "awarded_pending_checks"
    end

    context "with a received information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :received, assessment:)
      end

      include_examples "changes status", "received"

      it "changes received_further_information" do
        expect { call }.to change(
          application_form,
          :received_further_information,
        ).from(false).to(true)
      end
    end

    context "with a requested further information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_further_information" do
        expect { call }.to change(
          application_form,
          :waiting_on_further_information,
        ).from(false).to(true)
      end
    end

    context "with a requested profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:professional_standing_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_professional_standing" do
        expect { call }.to change(
          application_form,
          :waiting_on_professional_standing,
        ).from(false).to(true)
      end
    end

    context "with a received profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      context "when the teaching authority provides the written statement" do
        before do
          application_form.update!(
            submitted_at: Time.zone.now,
            teaching_authority_provides_written_statement: true,
          )
          create(:professional_standing_request, :received, assessment:)
        end

        include_examples "changes status", "submitted"

        it "doesn't change received_professional_standing" do
          expect { call }.to_not change(
            application_form,
            :received_professional_standing,
          ).from(false)
        end
      end

      context "when the teaching authority doesn't provide the written statement" do
        before do
          application_form.update!(submitted_at: Time.zone.now)
          create(:professional_standing_request, :received, assessment:)
        end

        include_examples "changes status", "received"

        it "changes received_professional_standing" do
          expect { call }.to change(
            application_form,
            :received_professional_standing,
          ).from(false).to(true)
        end
      end
    end

    context "with a received qualification request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:qualification_request, :received, assessment:)
      end

      include_examples "changes status", "received"

      it "changes received_further_information" do
        expect { call }.to change(
          application_form,
          :received_qualification,
        ).from(false).to(true)
      end
    end

    context "with a requested qualification request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:qualification_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_qualification" do
        expect { call }.to change(
          application_form,
          :waiting_on_qualification,
        ).from(false).to(true)
      end
    end

    context "with a received reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before { application_form.update!(submitted_at: Time.zone.now) }

      context "with less than 9 months" do
        before do
          create(:reference_request, :requested, assessment:)
          create(
            :reference_request,
            :received,
            assessment:,
            work_history:
              create(
                :work_history,
                application_form:,
                hours_per_week: 30,
                start_date: Date.new(2020, 1, 1),
                end_date: Date.new(2020, 2, 1),
              ),
          )
        end

        include_examples "changes status", "waiting_on"

        it "doesn't change received_reference" do
          expect { call }.to_not change(
            application_form,
            :received_reference,
          ).from(false)
        end
      end

      context "with less than 20 months" do
        before do
          create(
            :reference_request,
            :received,
            assessment:,
            work_history:
              create(
                :work_history,
                application_form:,
                hours_per_week: 30,
                start_date: Date.new(2020, 1, 1),
                end_date: Date.new(2020, 12, 1),
              ),
          )
        end

        context "and it's the only reference request" do
          include_examples "changes status", "received"

          it "changes received_reference" do
            expect { call }.to change(
              application_form,
              :received_reference,
            ).from(false).to(true)
          end
        end

        context "and there are other reference requests" do
          before { create(:reference_request, :requested, assessment:) }

          include_examples "changes status", "waiting_on"

          it "doesn't change received_reference" do
            expect { call }.to_not change(
              application_form,
              :received_reference,
            ).from(false)
          end
        end
      end

      context "with more than 20 months" do
        before do
          create(
            :reference_request,
            :received,
            assessment:,
            work_history:
              create(
                :work_history,
                application_form:,
                hours_per_week: 30,
                start_date: Date.new(2020, 1, 1),
                end_date: Date.new(2022, 12, 1),
              ),
          )
        end

        include_examples "changes status", "received"

        it "changes received_reference" do
          expect { call }.to change(application_form, :received_reference).from(
            false,
          ).to(true)
        end
      end
    end

    context "with a requested reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:reference_request, :requested, assessment:)
      end

      include_examples "changes status", "waiting_on"

      it "changes waiting_on_reference" do
        expect { call }.to change(application_form, :waiting_on_reference).from(
          false,
        ).to(true)
      end
    end

    context "with a started assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :started, application_form:)
      end

      include_examples "changes status", "initial_assessment"
    end

    context "with a submitted_at date" do
      before { application_form.update!(submitted_at: Time.zone.now) }

      include_examples "changes status", "submitted"
    end

    context "when status is unchanged" do
      it "doesn't change the status from draft" do
        expect { call }.to_not change(application_form, :status).from("draft")
      end

      it "doesn't record a timeline event" do
        expect { call }.to_not have_recorded_timeline_event(:state_changed)
      end
    end

    context "when preliminary check is required" do
      before do
        application_form.update!(
          assessment: create(:assessment, preliminary_check_complete: nil),
          submitted_at: Time.zone.now,
          requires_preliminary_check: true,
        )
      end

      include_examples "changes status", "preliminary_check"

      context "when teaching authority provides written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(
            :professional_standing_request,
            assessment: application_form.assessment,
          )
        end

        include_examples "changes status", "preliminary_check"

        context "once preliminary check is complete" do
          before do
            application_form.assessment.update!(
              preliminary_check_complete: true,
            )
          end

          include_examples "changes status", "waiting_on"
        end
      end
    end
  end
end

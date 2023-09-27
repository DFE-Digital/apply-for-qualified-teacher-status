# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationFormStatusUpdater do
  let(:application_form) { create(:application_form) }
  let(:user) { create(:staff) }

  shared_examples "changes action required by" do |new_action_required_by|
    it "changes action required by to #{new_action_required_by}" do
      expect { call }.to change(application_form, :action_required_by).to(
        new_action_required_by,
      )
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :action_required_by_changed,
        creator: user,
        application_form:,
        old_value: "none",
        new_value: new_action_required_by,
      )
    end
  end

  shared_examples "doesn't change action required by" do
    it "doesn't change action required by from none" do
      expect { call }.to_not change(application_form, :action_required_by).from(
        "none",
      )
    end

    it "doesn't record a timeline event" do
      expect { call }.to_not have_recorded_timeline_event(
        :action_required_by_changed,
        creator: user,
        application_form:,
      )
    end
  end

  shared_examples "changes stage" do |new_stage|
    it "changes status to #{new_stage}" do
      expect { call }.to change(application_form, :stage).to(new_stage)
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :stage_changed,
        creator: user,
        application_form:,
        old_value: "draft",
        new_value: new_stage,
      )
    end
  end

  shared_examples "changes status" do |new_status|
    it "changes status to #{new_status}" do
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

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "review"
      include_examples "changes status", "potential_duplicate_in_dqt"
    end

    context "with a withdrawn_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          withdrawn_at: Time.zone.now,
        )
      end

      include_examples "doesn't change action required by"
      include_examples "changes stage", "completed"
      include_examples "changes status", "withdrawn"
    end

    context "with a declined_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          declined_at: Time.zone.now,
        )
      end

      include_examples "doesn't change action required by"
      include_examples "changes stage", "completed"
      include_examples "changes status", "declined"
    end

    context "with an awarded_at date" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          awarded_at: Time.zone.now,
        )
      end

      include_examples "doesn't change action required by"
      include_examples "changes stage", "completed"
      include_examples "changes status", "awarded"
    end

    context "with a DQT TRN request" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:dqt_trn_request, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "review"
      include_examples "changes status", "awarded_pending_checks"
    end

    context "with a received information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:further_information_request, :received, assessment:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "assessment"
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

      include_examples "changes action required by", "external"
      include_examples "changes stage", "assessment"
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

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
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

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "not_started"
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

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "verification"
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

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "verification"
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

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
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

        include_examples "changes action required by", "external"
        include_examples "changes stage", "verification"
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
          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "verification"
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

          include_examples "changes action required by", "external"
          include_examples "changes stage", "verification"
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

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "verification"
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

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
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

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "assessment"
      include_examples "changes status", "assessment_in_progress"
    end

    context "with a submitted_at date" do
      before { application_form.update!(submitted_at: Time.zone.now) }

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "not_started"
      include_examples "changes status", "submitted"
    end

    context "when status is unchanged" do
      it "doesn't change the status from draft" do
        expect { call }.to_not change(application_form, :status).from("draft")
      end

      it "doesn't record a timeline event" do
        expect { call }.to_not have_recorded_timeline_event(:state_changed)
      end
      it "doesn't change the stage from draft" do
        expect { call }.to_not change(application_form, :stage).from("draft")
      end

      it "doesn't record a timeline event" do
        expect { call }.to_not have_recorded_timeline_event(:stage_changed)
      end

      include_examples "doesn't change action required by"
    end

    context "when preliminary check is required" do
      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          requires_preliminary_check: true,
        )
      end

      let(:assessment) { create(:assessment, application_form:) }

      let!(:preliminary_assessment_section) do
        create(:assessment_section, :preliminary, assessment:)
      end

      include_examples "changes action required by", "admin"
      include_examples "changes stage", "pre_assessment"
      include_examples "changes status", "preliminary_check"

      context "when teaching authority provides written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(:professional_standing_request, assessment:)
        end

        include_examples "changes action required by", "admin"
        include_examples "changes stage", "pre_assessment"
        include_examples "changes status", "preliminary_check"

        context "when the preliminary check has passed" do
          before { preliminary_assessment_section.update!(passed: true) }

          include_examples "changes action required by", "external"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes status", "waiting_on"
        end

        context "when the preliminary check has failed" do
          before do
            create(
              :selected_failure_reason,
              assessment_section: preliminary_assessment_section,
            )
            preliminary_assessment_section.reload.update!(passed: false)
          end

          include_examples "changes action required by", "admin"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes status", "preliminary_check"

          context "and the application form is declined" do
            before { application_form.update!(declined_at: Time.zone.now) }

            include_examples "doesn't change action required by"
            include_examples "changes stage", "completed"
            include_examples "changes status", "declined"
          end
        end
      end
    end
  end
end

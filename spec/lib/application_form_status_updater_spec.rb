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
      expect { call }.not_to change(application_form, :action_required_by).from(
        "none",
      )
    end

    it "doesn't record a timeline event" do
      expect { call }.not_to have_recorded_timeline_event(
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

  shared_examples "changes statuses" do |new_statuses|
    it "changes statuses to #{new_statuses}" do
      expect { call }.to change(application_form, :statuses).to(new_statuses)
    end
  end

  describe "#call" do
    subject(:call) { described_class.call(application_form:, user:) }

    context "with a potential duplicate in TRS" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:trs_trn_request, :potential_duplicate, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "review"
      include_examples "changes statuses", %w[potential_duplicate_in_dqt]
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
      include_examples "changes statuses", %w[withdrawn]
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
      include_examples "changes statuses", %w[declined]
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
      include_examples "changes statuses", %w[awarded]
    end

    context "with a TRS TRN request" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:trs_trn_request, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "review"
      include_examples "changes statuses", %w[awarded_pending_checks]
    end

    context "with a received further information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:received_further_information_request, assessment:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "assessment"
      include_examples "changes statuses", %w[received_further_information]
    end

    context "with a requested further information request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:requested_further_information_request, assessment:)
      end

      include_examples "changes action required by", "external"
      include_examples "changes stage", "assessment"
      include_examples "changes statuses", %w[waiting_on_further_information]
    end

    context "with a requested profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:requested_professional_standing_request, assessment:)
      end

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
      include_examples "changes statuses", %w[waiting_on_lops]
    end

    context "with a received profession standing request" do
      let(:assessment) { create(:assessment, application_form:) }

      context "when the teaching authority provides the written statement" do
        before do
          application_form.update!(
            submitted_at: Time.zone.now,
            teaching_authority_provides_written_statement: true,
          )
          create(:received_professional_standing_request, assessment:)
        end

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "not_started"
        include_examples "changes statuses", %w[assessment_not_started]
      end

      context "when the teaching authority doesn't provide the written statement" do
        before do
          application_form.update!(submitted_at: Time.zone.now)
          create(:received_professional_standing_request, assessment:)
        end

        include_examples "changes action required by", "admin"
        include_examples "changes stage", "verification"
        include_examples "changes statuses", %w[received_lops]
      end
    end

    context "with a received qualification request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:received_qualification_request, assessment:)
      end

      include_examples "changes action required by", "admin"
      include_examples "changes stage", "verification"
      include_examples "changes statuses", %w[received_ecctis]
    end

    context "with a requested qualification request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(
          :qualification_request,
          :requested,
          assessment:,
          consent_method: "unsigned",
        )
      end

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
      include_examples "changes statuses", %w[waiting_on_ecctis]
    end

    context "with a received reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before { application_form.update!(submitted_at: Time.zone.now) }

      context "with less than 9 months" do
        before do
          create(:requested_reference_request, assessment:)
          create(
            :received_reference_request,
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
        include_examples "changes statuses", %w[waiting_on_reference]
      end

      context "with less than 20 months" do
        before do
          create(
            :received_reference_request,
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
          include_examples "changes action required by", "admin"
          include_examples "changes stage", "verification"
          include_examples "changes statuses", %w[received_reference]
        end

        context "and there are other reference requests" do
          before { create(:requested_reference_request, assessment:) }

          include_examples "changes action required by", "external"
          include_examples "changes stage", "verification"
          include_examples "changes statuses", %w[waiting_on_reference]
        end
      end

      context "with more than 20 months" do
        before do
          create(
            :received_reference_request,
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

        include_examples "changes action required by", "admin"
        include_examples "changes stage", "verification"
        include_examples "changes statuses", %w[received_reference]
      end
    end

    context "with a requested reference request" do
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:requested_reference_request, assessment:)
      end

      include_examples "changes action required by", "external"
      include_examples "changes stage", "verification"
      include_examples "changes statuses", %w[waiting_on_reference]
    end

    context "when a reviewed assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :review, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "review"
      include_examples "changes statuses", %w[review]
    end

    context "with an assessment in verify" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :verify, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "verification"
      include_examples "changes statuses", %w[verification_in_progress]
    end

    context "with a started assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, :started, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "assessment"
      include_examples "changes statuses", %w[assessment_in_progress]
    end

    context "with an unstarted assessment" do
      before do
        application_form.update!(submitted_at: Time.zone.now)
        create(:assessment, application_form:)
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "not_started"
      include_examples "changes statuses", %w[assessment_not_started]
    end

    context "when status is unchanged" do
      include_examples "doesn't change action required by"

      it "doesn't change the stage from draft" do
        expect { call }.not_to change(application_form, :stage).from("draft")
      end

      it "doesn't record a timeline event" do
        expect { call }.not_to have_recorded_timeline_event(:stage_changed)
      end

      it "doesn't change the statuses from draft" do
        expect { call }.not_to change(application_form, :statuses).from(
          %w[draft],
        )
      end
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
      include_examples "changes statuses", %w[preliminary_check]

      context "when teaching authority provides written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(:requested_professional_standing_request, assessment:)
        end

        include_examples "changes action required by", "admin"
        include_examples "changes stage", "pre_assessment"
        include_examples "changes statuses",
                         %w[preliminary_check waiting_on_lops]

        context "when the preliminary check has passed" do
          before { preliminary_assessment_section.update!(passed: true) }

          include_examples "changes action required by", "external"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses", %w[waiting_on_lops]
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
          include_examples "changes statuses",
                           %w[preliminary_check waiting_on_lops]

          context "and the application form is declined" do
            before { application_form.update!(declined_at: Time.zone.now) }

            include_examples "doesn't change action required by"
            include_examples "changes stage", "completed"
            include_examples "changes statuses", %w[declined]
          end
        end
      end
    end

    context "when prioritisation check is required" do
      let!(:prioritisation_work_history_check) do
        create(:prioritisation_work_history_check, assessment:)
      end
      let(:assessment) { create(:assessment, application_form:) }

      before do
        application_form.update!(
          submitted_at: Time.zone.now,
          includes_prioritisation_features: true,
        )
      end

      include_examples "changes action required by", "assessor"
      include_examples "changes stage", "pre_assessment"
      include_examples "changes statuses", %w[prioritisation_check]

      context "when prioritisation checks have completed and have gone for references" do
        let!(:prioritisation_reference_request) do
          create(
            :requested_prioritisation_reference_request,
            assessment:,
            prioritisation_work_history_check:,
          )
        end

        before { prioritisation_work_history_check.update!(passed: true) }

        include_examples "changes action required by", "external"
        include_examples "changes stage", "pre_assessment"
        include_examples "changes statuses",
                         %w[
                           prioritisation_check
                           waiting_on_prioritisation_reference
                         ]

        context "with the reference received" do
          before do
            prioritisation_reference_request.update!(
              contact_response: true,
              confirm_applicant_response: true,
            )
            prioritisation_reference_request.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             received_prioritisation_reference
                           ]
        end

        context "with the reference expired" do
          before do
            prioritisation_reference_request.update!(expired_at: Time.current)
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             overdue_prioritisation_reference
                           ]
        end
      end

      context "when prioritisation checks have completed and have gone for multiple references" do
        let(:prioritisation_work_history_check_two) do
          create(:prioritisation_work_history_check, assessment:)
        end

        let!(:prioritisation_reference_request) do
          create(
            :requested_prioritisation_reference_request,
            assessment:,
            prioritisation_work_history_check:,
          )
        end

        let!(:prioritisation_reference_request_two) do
          create(
            :requested_prioritisation_reference_request,
            assessment:,
            prioritisation_work_history_check:
              prioritisation_work_history_check_two,
          )
        end

        before do
          prioritisation_work_history_check.update!(passed: true)
          prioritisation_work_history_check_two.update!(passed: true)
        end

        include_examples "changes action required by", "external"
        include_examples "changes stage", "pre_assessment"
        include_examples "changes statuses",
                         %w[
                           prioritisation_check
                           waiting_on_prioritisation_reference
                         ]

        context "with one of the references received" do
          before do
            prioritisation_reference_request.update!(
              contact_response: true,
              confirm_applicant_response: true,
            )
            prioritisation_reference_request.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             received_prioritisation_reference
                           ]
        end

        context "with one of the references received and passed review" do
          before do
            prioritisation_reference_request.update!(
              contact_response: true,
              confirm_applicant_response: true,
              review_passed: true,
            )
            prioritisation_reference_request.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses", %w[prioritisation_check]
        end

        context "with one of the references received and failed review" do
          before do
            prioritisation_reference_request.update!(
              contact_response: true,
              confirm_applicant_response: true,
              review_passed: false,
            )
            prioritisation_reference_request.received!
          end

          include_examples "changes action required by", "external"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             waiting_on_prioritisation_reference
                           ]
        end

        context "with both of the references received" do
          before do
            prioritisation_reference_request.update!(
              contact_response: true,
              confirm_applicant_response: true,
            )
            prioritisation_reference_request.received!

            prioritisation_reference_request_two.update!(
              contact_response: true,
              confirm_applicant_response: true,
            )
            prioritisation_reference_request_two.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             received_prioritisation_reference
                           ]
        end

        context "with one of the reference expired with another received" do
          before do
            prioritisation_reference_request.update!(expired_at: Time.current)

            prioritisation_reference_request_two.update!(
              contact_response: true,
              confirm_applicant_response: true,
            )
            prioritisation_reference_request_two.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             received_prioritisation_reference
                           ]
        end

        context "with one of the reference expired with another received and passed review" do
          before do
            prioritisation_reference_request.update!(expired_at: Time.current)

            prioritisation_reference_request_two.update!(
              contact_response: true,
              confirm_applicant_response: true,
              review_passed: true,
            )
            prioritisation_reference_request_two.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses", %w[prioritisation_check]
        end

        context "with one of the reference expired with another received and failed review" do
          before do
            prioritisation_reference_request.update!(expired_at: Time.current)

            prioritisation_reference_request_two.update!(
              contact_response: true,
              confirm_applicant_response: true,
              review_passed: false,
            )
            prioritisation_reference_request_two.received!
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             overdue_prioritisation_reference
                           ]
        end

        context "with both of the references expired" do
          before do
            prioritisation_reference_request.update!(expired_at: Time.current)
            prioritisation_reference_request_two.update!(
              expired_at: Time.current,
            )
          end

          include_examples "changes action required by", "assessor"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses",
                           %w[
                             prioritisation_check
                             overdue_prioritisation_reference
                           ]
        end
      end

      context "when the prioritsation decision has been made" do
        before { assessment.update!(prioritisation_decision_at: Time.current) }

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "not_started"
        include_examples "changes statuses", %w[assessment_not_started]
      end

      context "when teaching authority provides written statement" do
        before do
          application_form.update!(
            teaching_authority_provides_written_statement: true,
          )
          create(:requested_professional_standing_request, assessment:)
        end

        include_examples "changes action required by", "assessor"
        include_examples "changes stage", "pre_assessment"
        include_examples "changes statuses",
                         %w[prioritisation_check waiting_on_lops]

        context "when the prioritsation decision has been made" do
          before do
            assessment.update!(prioritisation_decision_at: Time.current)
          end

          include_examples "changes action required by", "external"
          include_examples "changes stage", "pre_assessment"
          include_examples "changes statuses", %w[waiting_on_lops]
        end
      end
    end
  end
end

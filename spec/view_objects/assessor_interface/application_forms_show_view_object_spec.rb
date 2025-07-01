# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsShowViewObject do
  subject(:view_object) do
    described_class.new(
      params: ActionController::Parameters.new(params),
      current_staff:,
    )
  end

  before { FeatureFlags::FeatureFlag.activate(:suitability) }

  after { FeatureFlags::FeatureFlag.deactivate(:suitability) }

  let(:params) { {} }
  let(:current_staff) { create(:staff) }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it "raise an error" do
      expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with a draft application form" do
      let(:params) do
        { reference: create(:application_form, :draft).reference }
      end

      it "raise an error" do
        expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with a submitted application form" do
      let(:params) do
        { reference: create(:application_form, :submitted).reference }
      end

      it { is_expected.not_to be_nil }
    end
  end

  describe "#task_list_sections" do
    subject(:task_list_sections) { view_object.task_list_sections }

    let(:application_form) { create(:application_form, :submitted) }
    let(:assessment) { create(:assessment, application_form:) }
    let!(:assessment_section) do
      create(:assessment_section, :personal_information, assessment:)
    end

    let(:params) { { reference: application_form.reference } }

    it do
      expect(subject).not_to include_task_list_item(
        "Pre-assessment tasks",
        "Preliminary check",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Pre-assessment tasks",
        "Check role, institution and referee details",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Pre-assessment tasks",
        "Check work history with referee",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Pre-assessment tasks",
        "Awaiting third-party professional standing",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Assessment",
        "Check personal information",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Assessment",
        "Check qualifications",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Assessment",
        "Check work history",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Assessment",
        "Check professional standing",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Assessment",
        "Initial assessment recommendation",
        status: :cannot_start,
      )
    end

    it { is_expected.not_to include_task_list_section("Verification") }
    it { is_expected.not_to include_task_list_section("Review") }

    context "with prioritisation checks" do
      let!(:first_prioritisation_work_history_check) do
        create(:prioritisation_work_history_check, assessment:)
      end

      let!(:second_prioritisation_work_history_check) do
        create(:prioritisation_work_history_check, assessment:)
      end

      it do
        expect(subject).to include_task_list_item(
          "Pre-assessment tasks",
          "Check role, institution and referee details",
          status: :not_started,
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Pre-assessment tasks",
          "Check work history with referee",
        )
      end

      context "when some checks are complete" do
        before do
          assessment.prioritisation_work_history_checks.first.update!(
            passed: true,
          )
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check role, institution and referee details",
            status: :in_progress,
          )
        end

        it do
          expect(subject).not_to include_task_list_item(
            "Pre-assessment tasks",
            "Check work history with referee",
          )
        end
      end

      context "when all checks are complete and not passed" do
        before do
          first_prioritisation_work_history_check.update!(passed: false)
          second_prioritisation_work_history_check.update!(passed: false)
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check role, institution and referee details",
            status: :completed,
          )
        end

        it do
          expect(subject).not_to include_task_list_item(
            "Pre-assessment tasks",
            "Check work history with referee",
          )
        end
      end

      context "when all checks are complete and only one passed" do
        before do
          first_prioritisation_work_history_check.update!(passed: true)
          second_prioritisation_work_history_check.update!(passed: false)
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check role, institution and referee details",
            status: :completed,
          )
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check work history with referee",
            status: :not_started,
            link: [
              :new,
              :assessor_interface,
              application_form,
              assessment,
              :prioritisation_reference_request,
            ],
          )
        end
      end

      context "when all checks are complete and passed" do
        before do
          first_prioritisation_work_history_check.update!(passed: true)
          second_prioritisation_work_history_check.update!(passed: true)
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check role, institution and referee details",
            status: :completed,
          )
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Check work history with referee",
            status: :not_started,
            link: [
              :new,
              :assessor_interface,
              application_form,
              assessment,
              :prioritisation_reference_request,
            ],
          )
        end

        context "with prioritisation references requested" do
          before do
            create :requested_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :requested_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :waiting_on,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with one prioritisation references received" do
          before do
            create :requested_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :received,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with both prioritisation references received" do
          before do
            create :received_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :received,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with one prioritisation references received and passed review" do
          before do
            create :requested_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   :review_passed,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :completed,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with one prioritisation references received and failed review" do
          before do
            create :requested_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   :review_failed,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :waiting_on,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with both prioritisation references received and passed review on one" do
          before do
            create :received_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   :review_passed,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :completed,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with both prioritisation references received and did not failed review on one" do
          before do
            create :received_prioritisation_reference_request,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   :review_failed,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :received,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end

        context "with both prioritisation references received and did not failed review on all" do
          before do
            create :received_prioritisation_reference_request,
                   :review_failed,
                   assessment:,
                   prioritisation_work_history_check:
                     first_prioritisation_work_history_check
            create :received_prioritisation_reference_request,
                   :review_failed,
                   assessment:,
                   prioritisation_work_history_check:
                     second_prioritisation_work_history_check
          end

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Check work history with referee",
              status: :completed,
              link: [
                :assessor_interface,
                application_form,
                assessment,
                :prioritisation_reference_requests,
              ],
            )
          end
        end
      end
    end

    context "when teaching authority provides written statement and a professional standing request" do
      let!(:professional_standing_request) do
        create(:professional_standing_request, assessment:)
      end

      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Pre-assessment tasks",
          "Awaiting third-party professional standing",
          status: :cannot_start,
        )
      end

      context "and professional standing request is requested" do
        before { professional_standing_request.requested! }

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Awaiting third-party professional standing",
            status: :waiting_on,
          )
        end
      end

      context "and professional standing request received" do
        before do
          professional_standing_request.update!(
            received_at: 1.day.ago,
            location_note: "wat",
          )
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Awaiting third-party professional standing",
            status: :completed,
          )
        end
      end
    end

    context "with a preliminary check" do
      let!(:assessment_section) do
        create(:assessment_section, :preliminary, assessment:)
      end

      it do
        expect(subject).to include_task_list_item(
          "Pre-assessment tasks",
          "Preliminary check (qualifications)",
          status: :not_started,
        )
      end

      context "when the check has passed" do
        before { assessment_section.update!(passed: true) }

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Preliminary check (qualifications)",
            status: :completed,
          )
        end
      end

      context "when the check has not passed" do
        before do
          create(
            :selected_failure_reason,
            assessment_section:,
            key: "teaching_qualifications_not_at_required_level",
          )
          assessment_section.reload.update!(passed: false)
        end

        it do
          expect(subject).to include_task_list_item(
            "Pre-assessment tasks",
            "Preliminary check (qualifications)",
            status: :in_progress,
          )
        end

        context "and the application has been declined" do
          before { assessment.decline! }

          it do
            expect(subject).to include_task_list_item(
              "Pre-assessment tasks",
              "Preliminary check (qualifications)",
              status: :completed,
            )
          end
        end
      end
    end

    context "with work history" do
      before { create(:assessment_section, :work_history, assessment:) }

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Check work history",
        )
      end
    end

    context "with professional standing statement" do
      before do
        create(:assessment_section, :professional_standing, assessment:)
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Check professional standing",
        )
      end
    end

    context "with finished assessment sections" do
      before { assessment_section.update!(passed: true) }

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Initial assessment recommendation",
          status: :not_started,
        )
      end

      context "and award" do
        before { assessment.award! }

        it do
          expect(subject).to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :completed,
          )
        end
      end

      context "and decline" do
        before { assessment.decline! }

        it do
          expect(subject).to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :completed,
          )
        end
      end

      context "and request further information" do
        before do
          assessment.request_further_information!
          create(
            :selected_failure_reason,
            :further_informationable,
            assessment_section:,
          )
          assessment_section.reload.update!(passed: false)
        end

        it do
          expect(subject).to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :in_progress,
          )
        end

        context "and further information requested" do
          before { create(:further_information_request, assessment:) }

          it do
            expect(subject).to include_task_list_item(
              "Assessment",
              "Initial assessment recommendation",
              status: :completed,
            )
          end
        end
      end
    end

    context "with a requested further information" do
      before { create(:requested_further_information_request, assessment:) }

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :cannot_start,
        )
      end
    end

    context "with a received further information" do
      before { create(:received_further_information_request, assessment:) }

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :not_started,
        )
      end
    end

    context "with a passed further information request" do
      before do
        assessment.request_further_information!
        create(
          :received_further_information_request,
          :review_passed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :in_progress,
        )
      end
    end

    context "with a failed further information request" do
      before do
        assessment.request_further_information!
        create(
          :received_further_information_request,
          :review_failed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :in_progress,
        )
      end
    end

    context "with a all items failed but not completed note" do
      before do
        assessment.request_further_information!
        further_information_request =
          create(
            :received_further_information_request,
            :with_items,
            assessment:,
          )
        further_information_request.items.update_all(review_decision: "decline")
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :in_progress,
        )
      end
    end

    context "with a passed further information request and a finished assessment" do
      before do
        assessment.award!
        create(
          :received_further_information_request,
          :review_passed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :completed,
        )
      end
    end

    context "with a failed further information request and a finished assessment" do
      before do
        assessment.decline!
        create(
          :received_further_information_request,
          :review_failed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :completed,
        )
      end
    end

    context "with multiple further information requests where one has failed and another one is requested" do
      before do
        assessment.request_further_information!
        create(
          :received_further_information_request,
          :with_items,
          :review_failed,
          assessment:,
          requested_at: 2.days.ago,
        )
        create(
          :received_further_information_request,
          :with_items,
          assessment:,
          requested_at: 1.day.ago,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :completed,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - second request",
          status: :not_started,
        )
      end

      context "with the new one being partially filled out" do
        before do
          assessment.reload.latest_further_information_request.items.update_all(
            review_decision: "accept",
          )
        end

        it do
          expect(subject).to include_task_list_item(
            "Assessment",
            "Review further information received - second request",
            status: :in_progress,
          )
        end
      end
    end

    context "with multiple further information requests where both have failed" do
      before do
        assessment.decline!
        create(
          :received_further_information_request,
          :review_failed,
          assessment:,
        )
        create(
          :received_further_information_request,
          :review_failed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :completed,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - second request",
          status: :completed,
        )
      end
    end

    context "with multiple further information requests where one failed and other accepted" do
      before do
        assessment.award!
        create(
          :received_further_information_request,
          :review_passed,
          assessment:,
        )
        create(
          :received_further_information_request,
          :review_passed,
          assessment:,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - first request",
          status: :completed,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Assessment",
          "Review further information received - second request",
          status: :completed,
        )
      end
    end

    context "with a professional standing request" do
      before do
        assessment.verify!
        create(:professional_standing_request, assessment:)
      end

      it do
        expect(subject).to include_task_list_item("Verification", "Verify LoPS")
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "with a qualification request" do
      before do
        assessment.verify!
        create(:qualification_request, assessment:)
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verify qualifications",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "without any verification steps but application awarded" do
      before { assessment.award! }

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify qualifications",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify references",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify LoPS",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "without any verification steps but application declined" do
      before { assessment.decline! }

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify qualifications",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify references",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verify LoPS",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "with a reference request" do
      before do
        assessment.verify!
        create(:reference_request, assessment:)
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verify references",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "with a failed verified professional standing request" do
      before do
        create(
          :professional_standing_request,
          assessment:,
          verify_passed: false,
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Review verifications",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Assessment decision",
        )
      end
    end

    context "with a failed verified qualification request" do
      before do
        create(:qualification_request, assessment:, verify_passed: false)
      end

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Review verifications",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Assessment decision",
        )
      end
    end

    context "with a failed verified reference request" do
      before { create(:reference_request, assessment:, verify_passed: false) }

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Review verifications",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "Review",
          "Assessment decision",
        )
      end
    end
  end

  describe "#email_used_as_reference_in_this_application_form?" do
    subject(:email_used_as_reference_in_this_application_form?) do
      view_object.email_used_as_reference_in_this_application_form?
    end

    let(:application_form) do
      create(
        :application_form,
        :submitted,
        teacher: create(:teacher, email: "same@gmail.com"),
      )
    end

    let(:params) { { reference: application_form.reference } }

    context "the email address is used as a reference" do
      before do
        create(
          :work_history,
          application_form:,
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.to be true }
    end

    context "the email address isn't used as a reference" do
      before do
        create(
          :work_history,
          application_form:,
          contact_email: "different@gmail.com",
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#other_application_forms_where_email_used_as_reference" do
    subject(:other_application_forms_where_email_used_as_reference) do
      view_object.other_application_forms_where_email_used_as_reference
    end

    let(:application_form) do
      create(
        :application_form,
        :submitted,
        teacher: create(:teacher, email: "same@gmail.com"),
      )
    end

    let(:params) { { reference: application_form.reference } }

    context "the email address is used as a reference" do
      before do
        create(
          :work_history,
          application_form: create(:application_form, :submitted),
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.not_to be_empty }
    end

    context "the email address isn't used as a reference" do
      before do
        create(
          :work_history,
          application_form: create(:application_form, :submitted),
          contact_email: "different@gmail.com",
        )
      end

      it { is_expected.to be_empty }
    end
  end

  describe "#highlight_email?" do
    subject(:highlight_email?) { view_object.highlight_email? }

    let(:application_form) do
      create(
        :application_form,
        :submitted,
        teacher: create(:teacher, email: "same@gmail.com"),
      )
    end

    let(:params) { { reference: application_form.reference } }

    context "the email address is used as a reference in the same application" do
      before do
        create(
          :work_history,
          application_form:,
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.to be true }
    end

    context "the email address is used as a reference in an other application" do
      before do
        create(
          :work_history,
          application_form: create(:application_form, :submitted),
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.to be true }
    end

    context "the email address isn't used as a reference" do
      before do
        create(
          :work_history,
          application_form:,
          contact_email: "different@gmail.com",
        )
      end

      it { is_expected.to be false }
    end
  end

  describe "#management_tasks" do
    subject(:management_tasks) { view_object.management_tasks }

    let(:application_form) do
      create(:application_form, :submitted, :with_assessment)
    end

    let(:params) { { reference: application_form.reference } }

    it { is_expected.to be_empty }

    context "with the correct permissions" do
      let(:current_staff) do
        create(
          :staff,
          :with_reverse_decision_permission,
          :with_withdraw_permission,
        )
      end

      it do
        expect(subject).to eq(
          [
            {
              name: "Reverse decision",
              link: [
                :rollback,
                :assessor_interface,
                application_form,
                application_form.assessment,
              ],
            },
            {
              name: "Withdraw",
              link: [:withdraw, :assessor_interface, application_form],
            },
          ],
        )
      end
    end
  end
end

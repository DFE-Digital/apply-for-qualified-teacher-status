# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ApplicationFormsShowViewObject do
  subject(:view_object) do
    described_class.new(
      params: ActionController::Parameters.new(params),
      current_staff:,
    )
  end

  let(:params) { {} }
  let(:current_staff) { create(:staff, :confirmed) }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it "raise an error" do
      expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "with a draft application form" do
      let(:params) { { id: create(:application_form, :draft).id } }

      it "raise an error" do
        expect { application_form }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with a submitted application form" do
      let(:params) { { id: create(:application_form, :submitted).id } }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#task_list_sections" do
    subject(:task_list_sections) { view_object.task_list_sections }

    let(:application_form) { create(:application_form, :submitted) }
    let(:assessment) { create(:assessment, application_form:) }
    let!(:assessment_section) do
      create(:assessment_section, :personal_information, assessment:)
    end

    let(:params) { { id: application_form.id } }

    it do
      is_expected.to_not include_task_list_item(
        "Pre-assessment tasks",
        "Preliminary check",
      )
    end
    it do
      is_expected.to_not include_task_list_item(
        "Pre-assessment tasks",
        "Awaiting third-party professional standing",
      )
    end

    it do
      is_expected.to include_task_list_item(
        "Assessment",
        "Check personal information",
      )
    end
    it do
      is_expected.to_not include_task_list_item(
        "Assessment",
        "Check qualifications",
      )
    end
    it do
      is_expected.to_not include_task_list_item(
        "Assessment",
        "Check work history",
      )
    end
    it do
      is_expected.to_not include_task_list_item(
        "Assessment",
        "Check professional standing",
      )
    end
    it do
      is_expected.to include_task_list_item(
        "Assessment",
        "Initial assessment recommendation",
        status: :cannot_start,
      )
    end

    it do
      is_expected.to_not include_task_list_section(
        "Further information requests",
      )
    end
    it { is_expected.to_not include_task_list_section("Verification") }

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
        is_expected.to include_task_list_item(
          "Pre-assessment tasks",
          "Awaiting third-party professional standing",
          status: :waiting_on,
        )
      end

      context "and professional standing request received" do
        before do
          professional_standing_request.update!(
            received_at: 1.day.ago,
            location_note: "wat",
          )
        end

        it do
          is_expected.to include_task_list_item(
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
        is_expected.to include_task_list_item(
          "Pre-assessment tasks",
          "Preliminary check (qualifications)",
          status: :not_started,
        )
      end

      context "when the check has passed" do
        before { assessment_section.update!(passed: true) }

        it do
          is_expected.to include_task_list_item(
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
          is_expected.to include_task_list_item(
            "Pre-assessment tasks",
            "Preliminary check (qualifications)",
            status: :in_progress,
          )
        end

        context "and the application has been declined" do
          before { assessment.decline! }

          it do
            is_expected.to include_task_list_item(
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
        is_expected.to include_task_list_item(
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
        is_expected.to include_task_list_item(
          "Assessment",
          "Check professional standing",
        )
      end
    end

    context "with finished assessment sections" do
      before { assessment_section.update!(passed: true) }

      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Initial assessment recommendation",
          status: :not_started,
        )
      end

      context "and award" do
        before { assessment.award! }
        it do
          is_expected.to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :completed,
          )
        end
      end

      context "and decline" do
        before { assessment.decline! }
        it do
          is_expected.to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :completed,
          )
        end
      end

      context "and request further information" do
        before do
          assessment.request_further_information!
          create(:selected_failure_reason, :fi_requestable, assessment_section:)
          assessment_section.reload.update!(passed: false)
        end

        it do
          is_expected.to include_task_list_item(
            "Assessment",
            "Initial assessment recommendation",
            status: :in_progress,
          )
        end

        context "and further information requested" do
          before { create(:further_information_request, assessment:) }
          it do
            is_expected.to include_task_list_item(
              "Assessment",
              "Initial assessment recommendation",
              status: :completed,
            )
          end
        end
      end
    end

    context "with a requested further information" do
      before { create(:further_information_request, :requested, assessment:) }

      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :cannot_start,
        )
      end
    end

    context "with a received further information" do
      before { create(:further_information_request, :received, assessment:) }

      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :not_started,
        )
      end
    end

    context "with a passed further information request" do
      before do
        assessment.request_further_information!
        create(:further_information_request, :received, :passed, assessment:)
      end

      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :in_progress,
        )
      end
    end

    context "with a failed further information request" do
      before do
        assessment.request_further_information!
        create(:further_information_request, :received, :failed, assessment:)
      end

      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :in_progress,
        )
      end
    end

    context "with a passed further information request and a finished assessment" do
      before do
        assessment.award!
        create(:further_information_request, :received, :passed, assessment:)
      end
      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :completed,
        )
      end
    end

    context "with a failed further information request and a finished assessment" do
      before do
        assessment.decline!
        create(:further_information_request, :received, :failed, assessment:)
      end
      it do
        is_expected.to include_task_list_item(
          "Assessment",
          "Review requested information from applicant",
          status: :completed,
        )
      end
    end

    context "with a professional standing request" do
      before { create(:professional_standing_request, assessment:) }

      it do
        is_expected.to include_task_list_item("Verification", "Verify LoPS")
      end
      it do
        is_expected.to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "with a qualification request" do
      before { create(:qualification_request, assessment:) }

      it do
        is_expected.to include_task_list_item(
          "Verification",
          "Record qualifications responses",
        )
      end
      it do
        is_expected.to include_task_list_item(
          "Verification",
          "Verification decision",
        )
      end
    end

    context "with a reference request" do
      before { create(:reference_request, assessment:) }

      it do
        is_expected.to include_task_list_item(
          "Verification",
          "Verify reference requests",
        )
      end
      it do
        is_expected.to include_task_list_item(
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
        is_expected.to include_task_list_item("Review", "Review verifications")
      end
      it do
        is_expected.to include_task_list_item("Review", "Assessment decision")
      end
    end

    context "with a failed verified qualification request" do
      before do
        create(:qualification_request, assessment:, verify_passed: false)
      end

      it do
        is_expected.to include_task_list_item("Review", "Review verifications")
      end
      it do
        is_expected.to include_task_list_item("Review", "Assessment decision")
      end
    end

    context "with a failed verified reference request" do
      before { create(:reference_request, assessment:, verify_passed: false) }

      it do
        is_expected.to include_task_list_item("Review", "Review verifications")
      end
      it do
        is_expected.to include_task_list_item("Review", "Assessment decision")
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

    let(:params) { { id: application_form.id } }

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

    let(:params) { { id: application_form.id } }

    context "the email address is used as a reference" do
      before do
        create(
          :work_history,
          application_form: create(:application_form, :submitted),
          contact_email: "same@gmail.com",
        )
      end

      it { is_expected.to_not be_empty }
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

    let(:params) { { id: application_form.id } }

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

    let(:params) { { id: application_form.id } }

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
        is_expected.to eq(
          [
            {
              title: "Reverse decision",
              path: [
                :rollback,
                :assessor_interface,
                application_form,
                application_form.assessment,
              ],
            },
            {
              title: "Withdraw",
              path: [:withdraw, :assessor_interface, application_form],
            },
          ],
        )
      end
    end
  end
end

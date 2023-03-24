# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ApplicationFormShowViewObject do
  subject(:view_object) { described_class.new(current_teacher:) }

  let(:current_teacher) { create(:teacher) }

  describe "#application_form" do
    subject(:application_form) { view_object.application_form }

    it { is_expected.to be_nil }

    context "with an application form" do
      before { create(:application_form, teacher: current_teacher) }

      it { is_expected.to_not be_nil }
    end
  end

  describe "#assessment" do
    subject(:assessment) { view_object.assessment }

    it { is_expected.to be_nil }

    context "with an assessment form" do
      before do
        application_form = create(:application_form, teacher: current_teacher)
        create(:assessment, application_form:)
      end

      it { is_expected.to_not be_nil }
    end
  end

  describe "#further_information_request" do
    subject(:further_information_request) do
      view_object.further_information_request
    end

    it { is_expected.to be_nil }

    context "with an application form" do
      before do
        application_form = create(:application_form, teacher: current_teacher)
        assessment = create(:assessment, application_form:)
        create(:further_information_request, assessment:)
      end

      it { is_expected.to_not be_nil }
    end
  end

  describe "#tasks" do
    subject(:tasks) { view_object.tasks }

    context "with needs work history" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: true,
          needs_written_statement: false,
          needs_registration_number: false,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            english_language: %i[english_language],
            qualifications: %i[qualifications age_range subjects],
            work_history: %i[work_history],
          },
        )
      end
    end

    context "with needs written statement" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: false,
          needs_written_statement: true,
          needs_registration_number: false,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            english_language: %i[english_language],
            qualifications: %i[qualifications age_range subjects],
            proof_of_recognition: %i[written_statement],
          },
        )
      end
    end

    context "with needs registration number" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: false,
          needs_written_statement: false,
          needs_registration_number: true,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: %i[personal_information identification_document],
            english_language: %i[english_language],
            qualifications: %i[qualifications age_range subjects],
            proof_of_recognition: %i[registration_number],
          },
        )
      end
    end
  end

  describe "#task_statuses" do
    subject(:task_statuses) { view_object.task_statuses }

    context "with no extra requirements" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: false,
          needs_written_statement: false,
          needs_registration_number: false,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            english_language: {
              english_language: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
          },
        )
      end
    end

    context "with work history" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: true,
          needs_written_statement: false,
          needs_registration_number: false,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            english_language: {
              english_language: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            work_history: {
              work_history: "not_started",
            },
          },
        )
      end
    end

    context "with written statement" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: false,
          needs_written_statement: true,
          needs_registration_number: false,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            english_language: {
              english_language: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            proof_of_recognition: {
              written_statement: "not_started",
            },
          },
        )
      end
    end

    context "with registration number" do
      before do
        create(
          :application_form,
          teacher: current_teacher,
          needs_work_history: false,
          needs_written_statement: false,
          needs_registration_number: true,
        )
      end

      it do
        is_expected.to eq(
          {
            about_you: {
              personal_information: "not_started",
              identification_document: "not_started",
            },
            english_language: {
              english_language: "not_started",
            },
            qualifications: {
              qualifications: "not_started",
              age_range: "not_started",
              subjects: "not_started",
            },
            proof_of_recognition: {
              registration_number: "not_started",
            },
          },
        )
      end
    end
  end

  describe "#completed_task_sections" do
    subject(:completed_task_sections) { view_object.completed_task_sections }

    let!(:application_form) do
      create(:application_form, teacher: current_teacher)
    end

    context "without any completed sections" do
      it { is_expected.to be_empty }
    end

    context "with a completed section" do
      before do
        application_form.update!(
          personal_information_status: "completed",
          identification_document_status: "completed",
        )
      end

      it { is_expected.to match_array(:about_you) }
    end
  end

  describe "#can_submit?" do
    subject(:can_submit?) { view_object.can_submit? }

    context "without any completed sections" do
      before { create(:application_form, teacher: current_teacher) }

      it { is_expected.to be false }
    end

    context "with a completed application form" do
      before { create(:application_form, :completed, teacher: current_teacher) }

      it { is_expected.to be true }
    end
  end

  describe "#notes_from_assessors" do
    subject(:notes_from_assessors) { view_object.notes_from_assessors }

    it { is_expected.to be_empty }

    context "with failure reasons" do
      let(:application_form) do
        create(:application_form, teacher: current_teacher)
      end
      let(:assessment) { create(:assessment, application_form:) }
      let(:assessment_section) do
        create(:assessment_section, :personal_information, :failed, assessment:)
      end
      let!(:failure_reasons) { assessment_section.selected_failure_reasons }

      it do
        is_expected.to eq(
          [
            {
              assessment_section_key: "personal_information",
              failure_reasons:
                failure_reasons.map do |failure_reason|
                  {
                    assessor_feedback: failure_reason.assessor_feedback,
                    is_decline: false,
                    key: failure_reason.key,
                  }
                end,
            },
          ],
        )
      end
    end
  end

  describe "#show_further_information_request_expired_content?" do
    let(:application_form) do
      create(:application_form, teacher: current_teacher)
    end
    let(:assessment) { create(:assessment, application_form:) }

    subject(:show_fi_expired) do
      view_object.show_further_information_request_expired_content?
    end

    context "when further_information_request is present" do
      context "and it has expired" do
        let!(:further_information_request) do
          create(:further_information_request, :expired, assessment:)
        end
        it { is_expected.to eq(true) }
      end

      context "and it hasn't expired" do
        let!(:further_information_request) do
          create(:further_information_request, assessment:)
        end
        it { is_expected.to eq(false) }
      end
    end

    context "when further_information_request is nil" do
      it { is_expected.to eq(false) }
    end
  end

  describe "#show_professional_standing_request_expired_content?" do
    let(:application_form) do
      create(:application_form, teacher: current_teacher)
    end
    let(:assessment) { create(:assessment, application_form:) }

    subject { view_object.show_professional_standing_request_expired_content? }

    context "when professional_standing_request is present" do
      context "and it has expired" do
        let!(:professional_standing_request) do
          create(:professional_standing_request, :expired, assessment:)
        end
        it { is_expected.to eq(true) }
      end

      context "and it hasn't expired" do
        let!(:professional_standing_request) do
          create(:professional_standing_request, assessment:)
        end
        it { is_expected.to eq(false) }
      end
    end

    context "when professional_standing_request is nil" do
      it { is_expected.to eq(false) }
    end
  end

  describe "#declined_cannot_reapply?" do
    subject(:declined_cannot_reapply?) { view_object.declined_cannot_reapply? }

    it { is_expected.to be false }

    context "with failure reasons" do
      let(:application_form) do
        create(:application_form, teacher: current_teacher)
      end
      let(:assessment) { create(:assessment, application_form:) }

      context "with sanctions" do
        let!(:assessment_section) do
          create(
            :assessment_section,
            :personal_information,
            :declines_with_sanctions,
            assessment:,
          )
        end

        it { is_expected.to be true }
      end

      context "with already QTS" do
        let!(:assessment_section) do
          create(
            :assessment_section,
            :personal_information,
            :declines_with_already_qts,
            assessment:,
          )
        end

        it { is_expected.to be true }
      end
    end
  end

  describe "#request_professional_standing_certificate?" do
    let(:assessment) { create(:assessment) }

    subject(:request_professional_standing_certificate?) do
      view_object.request_professional_standing_certificate?
    end

    context "when assessment preliminary checks are complete" do
      before do
        create(:application_form, assessment:, teacher: current_teacher)
        create(:professional_standing_request, assessment:)
        assessment.update!(preliminary_check_complete: true)
      end

      it { is_expected.to be true }
    end

    context "when application form written statement comes from teaching authority" do
      before do
        create(
          :application_form,
          assessment:,
          teacher: current_teacher,
          teaching_authority_provides_written_statement: true,
        )
        create(:professional_standing_request, assessment:)
      end

      it { is_expected.to be true }
    end

    context "when the application is not waiting on anything" do
      before do
        create(:application_form, assessment:, teacher: current_teacher)
        create(:professional_standing_request, :received, assessment:)
      end

      it { is_expected.to be false }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::ApplicationFormViewObject do
  subject(:view_object) { described_class.new(application_form:) }

  let(:country) { create(:country) }
  let(:region) { create(:region, country:) }
  let(:application_form) { create(:application_form, region:) }

  describe "#assessment" do
    subject(:assessment) { view_object.assessment }

    it { is_expected.to be_nil }

    context "with an assessment form" do
      before { create(:assessment, application_form:) }

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
        assessment = create(:assessment, application_form:)
        create(:further_information_request, assessment:)
      end

      it { is_expected.to_not be_nil }
    end
  end

  describe "#started_at" do
    subject(:started_at) { view_object.started_at }

    let(:application_form) do
      create(:application_form, created_at: Date.new(2020, 1, 1))
    end

    it { is_expected.to eq("1 January 2020") }
  end

  describe "#expires_at" do
    subject(:expires_at) { view_object.expires_at }

    let(:application_form) do
      create(:application_form, created_at: Date.new(2020, 1, 1))
    end

    it { is_expected.to eq("1 July 2020") }
  end

  describe "#task_list_sections" do
    subject(:task_list_sections) { view_object.task_list_sections }

    let(:needs_work_history) { false }
    let(:needs_written_statement) { false }
    let(:needs_registration_number) { false }

    let(:application_form) do
      create(
        :application_form,
        needs_work_history:,
        needs_written_statement:,
        needs_registration_number:,
      )
    end

    it do
      is_expected.to include_task_list_item(
        "About you",
        "Enter your personal information",
      )
    end
    it do
      is_expected.to include_task_list_item(
        "About you",
        "Upload your identity document",
      )
    end

    it do
      is_expected.to include_task_list_item(
        "Your English language proficiency",
        "Verify your English language proficiency",
      )
    end

    it do
      is_expected.to include_task_list_item(
        "Your qualifications",
        "Add your teaching qualifications",
      )
    end
    it do
      is_expected.to include_task_list_item(
        "Your qualifications",
        "Enter the age range you can teach",
      )
    end
    it do
      is_expected.to include_task_list_item(
        "Your qualifications",
        "Enter the subjects you can teach",
      )
    end

    it do
      is_expected.to_not include_task_list_item(
        "Your work history",
        "Add your work history",
      )
    end

    it do
      is_expected.to_not include_task_list_item(
        "Proof that you’re recognised as a teacher",
        "Upload your written statement",
      )
    end
    it do
      is_expected.to_not include_task_list_item(
        "Proof that you’re recognised as a teacher",
        "Enter your registration number",
      )
    end

    context "with needs work history" do
      let(:needs_work_history) { true }

      it do
        is_expected.to include_task_list_item(
          "Your work history",
          "Add your work history",
        )
      end
    end

    context "with needs written statement" do
      let(:needs_written_statement) { true }

      it do
        is_expected.to include_task_list_item(
          "Proof that you’re recognised as a teacher",
          "Upload your written statement",
        )
      end
    end

    context "with needs written statement" do
      let(:needs_registration_number) { true }

      it do
        is_expected.to include_task_list_item(
          "Proof that you’re recognised as a teacher",
          "Enter your registration number",
        )
      end
    end
  end

  describe "#completed_task_list_sections" do
    subject(:completed_task_list_sections) do
      view_object.completed_task_list_sections
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

      it { is_expected.to_not be_empty }
    end
  end

  describe "#can_submit?" do
    subject(:can_submit?) { view_object.can_submit? }

    context "without any completed sections" do
      it { is_expected.to be false }
    end

    context "with a completed application form" do
      let(:application_form) { create(:application_form, :completed) }

      it { is_expected.to be true }
    end
  end

  describe "#declined_reasons" do
    subject(:declined_reasons) { view_object.declined_reasons }

    it { is_expected.to be_empty }

    let(:assessment) { create(:assessment, application_form:) }

    context "when the country has been made ineligible" do
      let(:country) { create(:country, :ineligible, code: "ZW") }

      it do
        is_expected.to eq(
          {
            "" => [
              {
                name:
                  "As we are unable to verify professional standing documents with the " \
                    "teaching authority in Zimbabwe, we have removed Zimbabwe from the " \
                    "list of eligible countries.\n\nWe need to be able to verify all " \
                    "documents submitted by applicants with the relevant authorities. " \
                    "This is to ensure QTS requirements are applied fairly and consistently " \
                    "to every teacher, regardless of the country they trained to teach in.",
              },
            ],
          },
        )
      end
    end

    context "when further_information_request is present and expired" do
      before { create(:further_information_request, :expired, assessment:) }
      it do
        is_expected.to eq(
          {
            "" => [
              {
                name:
                  "Your application has been declined as you did not respond to the " \
                    "assessor’s request for further information within the specified time.",
              },
            ],
          },
        )
      end
    end

    context "when professional_standing_request is present and expired" do
      before { create(:professional_standing_request, :expired, assessment:) }
      it do
        is_expected.to eq(
          {
            "" => [
              {
                name:
                  "Your application has been declined as we did not receive your Letter " \
                    "of Professional Standing from teaching authority within 180 days.",
              },
            ],
          },
        )
      end
    end

    context "with a recommendation note" do
      before { assessment.update!(recommendation_assessor_note: "A note.") }
      it { is_expected.to eq({ "" => [{ name: "A note." }] }) }
    end

    context "with failure reasons" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::QUALIFIED_TO_TEACH,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::AGE_RANGE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end
      let!(:failure_reasons) { assessment_section.selected_failure_reasons }

      it do
        is_expected.to eq(
          {
            "Personal information" => [
              {
                assessor_note: "A note.",
                name:
                  "The age range you are qualified to teach does not fall " \
                    "within the requirements of QTS.",
              },
              {
                name:
                  "We were not provided with sufficient evidence to confirm " \
                    "qualification to teach at state or government schools.",
              },
            ],
          },
        )
      end
    end
  end

  describe "#declined_cannot_reapply?" do
    subject(:declined_cannot_reapply?) { view_object.declined_cannot_reapply? }

    it { is_expected.to be false }

    context "with an assessment" do
      let!(:assessment) { create(:assessment, application_form:) }

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

  describe "#from_ineligible_country?" do
    subject(:from_ineligible_country?) { view_object.from_ineligible_country? }

    it { is_expected.to be false }

    context "with an ineligible country" do
      let(:country) { create(:country, :ineligible) }
      let(:application_form) do
        create(:application_form, region: create(:region, country:))
      end

      it { is_expected.to be true }
    end
  end

  describe "#request_professional_standing_certificate?" do
    subject(:request_professional_standing_certificate?) do
      view_object.request_professional_standing_certificate?
    end

    let(:assessment) { create(:assessment, application_form:) }

    it { is_expected.to be false }

    context "when the teaching authority provides the written statement" do
      let(:application_form) do
        create(
          :application_form,
          teaching_authority_provides_written_statement: true,
        )
      end

      before { create(:professional_standing_request, :requested, assessment:) }

      context "when there are preliminary checks and they are not complete" do
        before do
          application_form.update!(requires_preliminary_check: true)
          create(:assessment_section, :preliminary, assessment:)
        end

        it { is_expected.to be false }
      end

      context "when there are preliminary checks and they are complete" do
        before do
          application_form.update!(requires_preliminary_check: true)
          create(:assessment_section, :preliminary, :passed, assessment:)
        end

        it { is_expected.to be true }
      end

      context "when there are no preliminary checks" do
        before { application_form.update!(requires_preliminary_check: false) }

        it { is_expected.to be true }
      end
    end
  end
end

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

      it { is_expected.not_to be_nil }
    end
  end

  describe "#further_information_request" do
    subject(:further_information_request) do
      view_object.further_information_request
    end

    it { is_expected.to be_nil }

    context "with a further information request" do
      before do
        assessment = create(:assessment, application_form:)
        create(:further_information_request, assessment:)
      end

      it { is_expected.not_to be_nil }
    end

    context "with multiple further information requests" do
      let(:assessment) { create(:assessment, application_form:) }

      let!(:new_further_information_request) do
        create(
          :further_information_request,
          assessment:,
          requested_at: 1.day.ago,
        )
      end

      before do
        create(
          :further_information_request,
          assessment:,
          requested_at: 2.days.ago,
        )
      end

      it { is_expected.to eq(new_further_information_request) }
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
      expect(subject).to include_task_list_item(
        "About you",
        "Enter your personal information",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "About you",
        "Upload your identity document",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Your English language proficiency",
        "Verify your English language proficiency",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Your qualifications",
        "Add your teaching qualifications",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Your qualifications",
        "Enter the age range you can teach",
      )
    end

    it do
      expect(subject).to include_task_list_item(
        "Your qualifications",
        "Enter the subjects you can teach",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Your work history",
        "Add your work history",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Proof that you’re recognised as a teacher",
        "Upload your written statement",
      )
    end

    it do
      expect(subject).not_to include_task_list_item(
        "Proof that you’re recognised as a teacher",
        "Enter your registration number",
      )
    end

    context "with needs work history" do
      let(:needs_work_history) { true }

      it do
        expect(subject).to include_task_list_item(
          "Your work history",
          "Add your work history",
        )
      end

      it do
        expect(subject).not_to include_task_list_item(
          "Your work history",
          "Add other work experience in England",
        )
      end

      context "when work history is completed" do
        before { application_form.update!(work_history_status: :completed) }

        it do
          expect(subject).not_to include_task_list_item(
            "Your work history",
            "Add other work experience in England",
          )
        end
      end

      context "when the application form includes prioritisation features" do
        before do
          application_form.update!(includes_prioritisation_features: true)
        end

        it do
          expect(subject).to include_task_list_item(
            "Your work history",
            "Add your work history",
          )
        end

        it do
          expect(subject).not_to include_task_list_item(
            "Your work history",
            "Add other work experience in England",
          )
        end

        context "when work history is completed" do
          before { application_form.update!(work_history_status: :completed) }

          it do
            expect(subject).to include_task_list_item(
              "Your work history",
              "Add other work experience in England",
            )
          end
        end
      end
    end

    context "with needs written statement" do
      let(:needs_written_statement) { true }

      it do
        expect(subject).to include_task_list_item(
          "Proof that you’re recognised as a teacher",
          "Upload your written statement",
        )
      end
    end

    context "with needs registration number" do
      let(:needs_registration_number) { true }

      it do
        expect(subject).to include_task_list_item(
          "Proof that you’re recognised as a teacher",
          "Enter your registration number",
        )
      end
    end

    context "requires passport upload for identification" do
      before do
        application_form.update!(requires_passport_as_identity_proof: true)
      end

      it do
        expect(subject).not_to include_task_list_item(
          "About you",
          "Upload your identity document",
        )
      end

      it do
        expect(subject).to include_task_list_item(
          "About you",
          "Upload your passport",
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

      it { is_expected.not_to be_empty }
    end
  end

  describe "#can_submit?" do
    subject(:can_submit?) { view_object.can_submit? }

    context "without any completed sections" do
      it { is_expected.to be false }
    end

    context "with a completed application form" do
      let(:application_form) do
        create(
          :application_form,
          :with_personal_information,
          :with_identification_document,
          :with_degree_qualification,
          :with_age_range,
          :with_subjects,
          :with_work_history,
          :with_written_statement,
          :with_english_language_provider,
        )
      end

      it { is_expected.to be true }
    end
  end

  describe "#declined_reasons" do
    subject(:declined_reasons) { view_object.declined_reasons }

    let(:assessment) { create(:assessment, application_form:) }

    it { is_expected.to be_empty }

    context "when the country has been made ineligible" do
      let(:country) { create(:country, :ineligible, code: "ZW") }

      it do
        expect(subject).to eq(
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
        expect(subject).to eq(
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
        expect(subject).to eq(
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

    context "with failure reasons that include FI and Declines" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it "only returns the declined reasons" do
        expect(subject).to eq(
          {
            "About you" => [
              {
                assessor_note: "A note.",
                name:
                  "Your passport had already expired when the application was submitted.",
              },
              {
                assessor_note: "A note.",
                name: "You already have an application in progress.",
              },
            ],
          },
        )
      end
    end

    context "with failure reasons that include declines that prevent applicant from reapplying" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::AUTHORISATION_TO_TEACH,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it "only returns the declined reasons that prevents from reapplying" do
        expect(subject).to eq(
          {
            "" => [
              {
                name:
                  "Sanctions or restrictions were detected on your professional record.",
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
        before do
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
        before do
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

  describe "#preliminary_check_pending?" do
    subject(:preliminary_check_pending?) do
      view_object.preliminary_check_pending?
    end

    let(:assessment) { create(:assessment, application_form:) }

    it { is_expected.to be false }

    context "when the application requires preliminary checks and it hasn't passed" do
      let(:region) { create(:region, :requires_preliminary_check, country:) }
      let(:application_form) do
        create(:application_form, :requires_preliminary_check, region:)
      end

      before { create :assessment_section, :preliminary, assessment: }

      it { is_expected.to be true }
    end

    context "when the application requires preliminary checks and it has passed" do
      let(:region) { create(:region, :requires_preliminary_check, country:) }
      let(:application_form) do
        create(:application_form, :requires_preliminary_check, region:)
      end

      before { create :assessment_section, :preliminary, :passed, assessment: }

      it { is_expected.to be false }
    end

    context "when the application requires preliminary checks but there is no assessment yet" do
      let(:region) { create(:region, :requires_preliminary_check, country:) }
      let(:application_form) do
        create(:application_form, :requires_preliminary_check, region:)
      end
      let(:assessment) { nil }

      it { is_expected.to be false }
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

      before { create(:requested_professional_standing_request, assessment:) }

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

  describe "#letter_of_professional_standing_received?" do
    subject(:letter_of_professional_standing_received?) do
      view_object.letter_of_professional_standing_received?
    end

    let(:application_form) do
      create(:application_form, :teaching_authority_provides_written_statement)
    end

    let(:assessment) { create(:assessment, application_form:) }

    it { is_expected.to be false }

    context "when there is a professional standing request" do
      let!(:requested_professional_standing_request) do
        create(:requested_professional_standing_request, assessment:)
      end

      it { is_expected.to be false }

      context "with the status being received" do
        before do
          requested_professional_standing_request.update(
            received_at: Time.current,
          )
        end

        it { is_expected.to be true }
      end
    end

    context "when there is no assessment" do
      let(:assessment) { nil }

      it { is_expected.to be false }
    end
  end

  describe "#passport_expiry_date_expired?" do
    subject(:passport_expiry_date_expired?) do
      view_object.passport_expiry_date_expired?
    end

    let(:application_form) do
      create(:application_form, region:, passport_expiry_date:)
    end
    let(:passport_expiry_date) {}

    context "when passport expiry date is in the past" do
      let(:passport_expiry_date) { Date.new(2.years.ago.year, 1, 1) }

      it { is_expected.to be true }
    end

    context "when passport expiry date is today" do
      let(:passport_expiry_date) { Date.current }

      it { is_expected.to be false }
    end

    context "when passport expiry date is in the future" do
      let(:passport_expiry_date) { Date.new(2.years.from_now.year, 1, 1) }

      it { is_expected.to be false }
    end

    context "when passport expiry date is nil" do
      let(:passport_expiry_date) { nil }

      it { is_expected.to be false }
    end
  end

  describe "#prioritisation_checks_pending?" do
    subject(:prioritisation_checks_pending?) do
      view_object.prioritisation_checks_pending?
    end

    let(:application_form) { create(:application_form, region:) }

    let(:assessment) { create(:assessment, application_form:) }

    context "when assessment has no prioritisation work history checks" do
      it { is_expected.to be false }
    end

    context "when assessment has prioritisation work history checks" do
      before { create :prioritisation_work_history_check, assessment: }

      it { is_expected.to be true }

      context "when prioritisation decision has been is made" do
        before do
          assessment.update!(
            prioritisation_decision_at: Time.current,
            prioritised: true,
          )
        end

        it { is_expected.to be false }
      end
    end
  end

  describe "#show_new_requirements_for_work_history_references_banner?" do
    subject(:show_new_requirements_for_work_history_references_banner?) do
      view_object.show_new_requirements_for_work_history_references_banner?
    end

    context "when the feature flag email domains for referees is enabled" do
      before { FeatureFlags::FeatureFlag.activate(:email_domains_for_referees) }

      after do
        FeatureFlags::FeatureFlag.deactivate(:email_domains_for_referees)
      end

      it { is_expected.to be true }

      context "when the application form started after the release of the feature" do
        before do
          application_form.update!(started_with_private_email_for_referee: true)
        end

        it { is_expected.to be false }
      end

      context "when the application form has in progress status for work history" do
        before { application_form.update!(work_history_status: "in_progress") }

        it { is_expected.to be true }
      end

      context "when the application form has update needed status for work history" do
        before do
          application_form.update!(work_history_status: "update_needed")
        end

        it { is_expected.to be true }
      end

      context "when the application form has completed work history and in progress other England work history" do
        before do
          application_form.update!(
            work_history_status: "completed",
            other_england_work_history_status: "in_progress",
          )
        end

        it { is_expected.to be true }
      end

      context "when the application form has completed work history and update needed other England work history" do
        before do
          application_form.update!(
            work_history_status: "completed",
            other_england_work_history_status: "update_needed",
          )
        end

        it { is_expected.to be true }
      end

      context "when the application form has completed work history and other England work history" do
        before do
          application_form.update!(
            work_history_status: "completed",
            other_england_work_history_status: "completed",
          )
        end

        it { is_expected.to be false }
      end
    end

    context "when the feature flag email domains for referees is disabled" do
      it { is_expected.to be false }
    end
  end

  describe "#has_any_further_information_decline_reasons?" do
    subject(:has_any_further_information_decline_reasons?) do
      view_object.has_any_further_information_decline_reasons?
    end

    let(:assessment) { create(:assessment, application_form:) }

    context "with failure reasons that includes FI" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it { is_expected.to be true }
    end

    context "with failure reasons that includes FI but FI request has already been sent" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before do
        assessment_section.selected_failure_reasons

        create :received_further_information_request, assessment:
      end

      it { is_expected.to be false }
    end

    context "with failure reasons that only has decline" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it { is_expected.to be false }
    end

    context "without any assessment sections failing" do
      let(:assessment_section) do
        create(:assessment_section, :personal_information, :passed, assessment:)
      end

      it { is_expected.to be false }
    end
  end

  describe "#assessment_further_information_reasons" do
    subject(:assessment_further_information_reasons) do
      view_object.assessment_further_information_reasons
    end

    let(:assessment) { create(:assessment, application_form:) }

    context "with failure reasons that includes FI" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it "only returns the FI reasons" do
        expect(subject).to eq(
          {
            "About you" => [
              {
                assessor_note: "A note.",
                name:
                  "There is a problem with your passport. For example, it’s incorrect, illegible, or incomplete.",
              },
            ],
          },
        )
      end
    end

    context "with failure reasons that includes FI but FI request has already been sent" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before do
        assessment_section.selected_failure_reasons

        create :received_further_information_request, assessment:
      end

      it "only returns empty object" do
        expect(subject).to eq({})
      end
    end

    context "with failure reasons that only has decline" do
      let(:assessment_section) do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "A note.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "A note.",
            ),
          ],
        )
      end

      before { assessment_section.selected_failure_reasons }

      it "only returns empty object" do
        expect(subject).to eq({})
      end
    end

    context "without any assessment sections failing" do
      let(:assessment_section) do
        create(:assessment_section, :personal_information, :passed, assessment:)
      end

      it "only returns empty object" do
        expect(subject).to eq({})
      end
    end
  end
end

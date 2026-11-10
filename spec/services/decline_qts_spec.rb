# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeclineQTS do
  subject(:call) { described_class.call(application_form:, user:) }

  let(:teacher) { create(:teacher) }
  let(:user) { create(:staff) }

  context "with an application form" do
    let(:application_form) do
      create(:application_form, :submitted, :with_assessment, teacher:)
    end

    let(:decline_event) do
      application_form.timeline_events.application_declined.sole
    end

    let(:assessment) { application_form.assessment }

    it "sends an email" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      ).with(params: { application_form: }, args: [])
    end

    it "changes the stage" do
      expect { call }.to change(application_form, :stage).to("completed")
    end

    it "changes the statuses" do
      expect { call }.to change(application_form, :statuses).to(%w[declined])
    end

    it "sets the declined at date" do
      freeze_time do
        expect { call }.to change(application_form, :declined_at).to(
          Time.zone.now,
        )
      end
    end

    it "records a timeline event" do
      expect { call }.to have_recorded_timeline_event(
        :application_declined,
        creator: user,
        application_form:,
      )
    end

    it "persists an snapshot of declined reasons" do
      call

      expect(decline_event.reload.event_data).to eq("declined_reasons" => {})
    end

    context "with an assessor recommendation note" do
      before do
        assessment.update!(
          recommendation_assessor_note: "Original decline note.",
        )
      end

      it "persists the assessor note as part of event_data" do
        call

        expect(decline_event.reload.event_data).to eq(
          "declined_reasons" => {
            "" => [{ "name" => "Original decline note." }],
          },
        )
      end
    end

    context "with multiple initial-assessment reasons" do
      before do
        create(
          :assessment_section,
          :personal_information,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_EXPIRED,
              assessor_feedback: "Original passport feedback.",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::DUPLICATE_APPLICATION,
              assessor_feedback: "",
            ),
            build(
              :selected_failure_reason,
              key: FailureReasons::PASSPORT_DOCUMENT_ILLEGIBLE,
              assessor_feedback: "Further information only.",
            ),
          ],
        )
        create(
          :assessment_section,
          :qualifications,
          :failed,
          assessment:,
          selected_failure_reasons: [
            build(
              :selected_failure_reason,
              key:
                FailureReasons::TEACHING_QUALIFICATIONS_NOT_AT_REQUIRED_LEVEL,
              assessor_feedback: "Original qualification feedback.",
            ),
          ],
        )
        assessment.update!(
          recommendation_assessor_note: "Original recommendation.",
        )
      end

      let(:expected_reasons) do
        {
          "" => [{ "name" => "Original recommendation." }],
          "About you" => [
            {
              "name" =>
                "Your passport had already expired when the application was submitted.",
              "assessor_note" => "Original passport feedback.",
            },
            { "name" => "You already have an application in progress." },
          ],
          "Your qualifications" => [
            {
              "name" =>
                I18n.t(
                  FailureReasons::TEACHING_QUALIFICATIONS_NOT_AT_REQUIRED_LEVEL,
                  scope: %i[
                    teacher_interface
                    application_forms
                    show
                    declined
                    failure_reasons
                  ],
                ),
              "assessor_note" => "Original qualification feedback.",
            },
          ],
        }
      end

      it "saves every decline reason and feedback grouped by section" do
        call

        expect(decline_event.reload.event_data).to eq(
          "declined_reasons" => expected_reasons,
        )
      end
    end

    context "when a further information request expires" do
      let(:requestable) do
        create(:requested_further_information_request, assessment:)
      end

      it "captures the expiry reason through the expiry callback" do
        ExpireRequestable.call(requestable:, user:)

        expect(decline_event.reload.event_data).to eq(
          "declined_reasons" => {
            "" => [
              {
                "name" =>
                  I18n.t(
                    "teacher_interface.application_forms.show.declined.failure_reasons.further_information_request_expired",
                  ),
              },
            ],
          },
        )
      end
    end

    context "when a professional standing request expires" do
      let(:requestable) do
        create(:requested_professional_standing_request, assessment:)
      end

      before do
        application_form.update!(
          teaching_authority_provides_written_statement: true,
        )
      end

      it "captures the expiry reason through the expiry callback" do
        ExpireRequestable.call(requestable:, user:)

        expect(decline_event.reload.event_data).to eq(
          "declined_reasons" => {
            "" => [
              {
                "name" =>
                  "Your application has been declined as we did not receive your Letter " \
                    "of Professional Standing from teaching authority within 180 days.",
              },
            ],
          },
        )
      end
    end
  end

  context "with a declined application form" do
    let(:application_form) do
      create(:application_form, :declined, :with_assessment, teacher:)
    end

    it "doesn't send an email" do
      expect { call }.not_to have_enqueued_mail(
        TeacherMailer,
        :application_declined,
      )
    end

    it "doesn't change the stage" do
      expect { call }.not_to change(application_form, :stage)
    end

    it "doesn't change the declined at date" do
      expect { call }.not_to change(application_form, :declined_at)
    end

    it "doesn't record a timeline event" do
      expect { call }.not_to have_recorded_timeline_event(
        :application_declined,
        creator: user,
        application_form:,
      )
    end
  end
end

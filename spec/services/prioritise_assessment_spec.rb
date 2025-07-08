# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrioritiseAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) do
    create(:application_form, :teaching_authority_provides_written_statement)
  end
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  before { allow(ApplicationFormStatusUpdater).to receive(:call) }

  context "when assessment can be prioritised" do
    before do
      create :received_prioritisation_reference_request,
             assessment:,
             review_passed: true
    end

    it "updates the prioritisation decision on assessment" do
      call

      expect(assessment.prioritised).to be true
      expect(assessment.prioritisation_decision_at).not_to be_nil
    end

    it "calls the ApplicationFormStatusUpdater" do
      call

      expect(ApplicationFormStatusUpdater).to have_received(:call).with(
        application_form:,
        user:,
      )
    end

    it "sends the prioritised email to the applicant" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :application_prioritised,
      ).with(params: { application_form: }, args: [])
    end

    context "when the assessment has professional standing request" do
      context "when the professional standing request is already requested" do
        let!(:professional_standing_request) do
          create :requested_professional_standing_request, assessment:
        end

        it "sends the prioritised email to the applicant" do
          expect { call }.to have_enqueued_mail(
            TeacherMailer,
            :application_prioritised,
          ).with(params: { application_form: }, args: [])
        end

        it "does not send the requested LoPs email to the applicant" do
          expect { call }.not_to have_enqueued_mail(
            TeacherMailer,
            :professional_standing_requested,
          )
        end

        it "does not re-request the LoPs" do
          expect { call }.not_to change(
            professional_standing_request,
            :requested?,
          )
        end
      end

      context "when the professional standing request is not already requested" do
        let!(:professional_standing_request) do
          create :professional_standing_request, assessment:
        end

        it "does not send the prioritised email to the applicant" do
          expect { call }.not_to have_enqueued_mail(
            TeacherMailer,
            :application_prioritised,
          )
        end

        it "sends requested LoPs email to the applicant" do
          expect { call }.to have_enqueued_mail(
            TeacherMailer,
            :professional_standing_requested,
          ).with(params: { application_form: }, args: [])
        end

        it "requests the LoPs" do
          expect { call }.to change(
            professional_standing_request,
            :requested?,
          ).from(false).to(true)
        end
      end
    end
  end

  context "when assessment cannot be prioritised" do
    before do
      create :received_prioritisation_reference_request,
             assessment:,
             review_passed: false
    end

    it "raises InvalidState error" do
      expect { call }.to raise_error(PrioritiseAssessment::InvalidState)
    end
  end
end

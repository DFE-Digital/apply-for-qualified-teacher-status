# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeprioritiseAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }

  before { allow(ApplicationFormStatusUpdater).to receive(:call) }

  context "when assessment can be deprioritised" do
    before do
      create :received_prioritisation_reference_request,
             assessment:,
             review_passed: false
    end

    it "updates the prioritisation decision on assessment" do
      call

      expect(assessment.prioritised).to be false
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
        :application_not_prioritised,
      ).with(params: { application_form: }, args: [])
    end

    it "does not generate a new preliminary assessment section" do
      expect { call }.not_to change(assessment.sections.preliminary, :count)
    end

    context "when the application form requires preliminary checks" do
      let(:application_form) do
        create(:application_form, :requires_preliminary_check)
      end

      it "generates a new preliminary assessment section for qualifications" do
        expect { call }.to change(assessment.sections.preliminary, :count).by(1)
      end
    end
  end

  context "when assessment can be prioritised" do
    before do
      create :received_prioritisation_reference_request,
             assessment:,
             review_passed: true
    end

    it "raises InvalidState error" do
      expect { call }.to raise_error(DeprioritiseAssessment::InvalidState)
    end
  end

  context "when assessment has not yet completed prioritisation checks" do
    before { create :received_prioritisation_reference_request, assessment: }

    it "raises InvalidState error" do
      expect { call }.to raise_error(DeprioritiseAssessment::InvalidState)
    end
  end
end

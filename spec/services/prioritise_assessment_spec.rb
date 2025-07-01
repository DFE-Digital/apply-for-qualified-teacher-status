# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrioritiseAssessment do
  subject(:call) { described_class.call(assessment:, user:) }

  let(:application_form) { create(:application_form) }
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

# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateAssessmentRecommendation do
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff) }
  let(:new_recommendation) { :award }

  subject(:call) do
    described_class.call(assessment:, user:, new_recommendation:)
  end

  describe "assessment recommendation" do
    subject(:recommendation) { assessment.recommendation }

    it { is_expected.to eq("unknown") }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("award") }
    end
  end

  describe "application form status" do
    subject(:state) { application_form.state }

    it { is_expected.to eq("submitted") }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("awarded") }
    end
  end
end

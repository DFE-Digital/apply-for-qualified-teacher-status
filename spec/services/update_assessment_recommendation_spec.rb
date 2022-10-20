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

  describe "assessment recommendation date" do
    subject(:recommended_at) { assessment.recommended_at }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }
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

  context "request further information recommendataion" do
    let(:new_recommendation) { :request_further_information }

    describe "recommendation" do
      subject(:recommendation) { assessment.recommendation }

      it { is_expected.to eq("unknown") }

      context "after calling the service" do
        before { call }

        it { is_expected.to eq("request_further_information") }
      end
    end

    describe "application form status" do
      it "doesn't change the state" do
        expect { call }.to_not change(application_form, :state)
      end
    end
  end
end

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

  before do
    allow(CreateDQTTRNRequest).to receive(:call).with(application_form:)
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

      it { is_expected.to eq("awarded_pending_checks") }
    end
  end

  context "award recommendation" do
    let(:new_recommendation) { "award" }

    describe "application declined email" do
      it "doesn't send an email" do
        expect { call }.to_not have_enqueued_mail(
          TeacherMailer,
          :application_declined,
        )
      end
    end

    describe "DQT TRN request job" do
      it "creates a DQT TRN request" do
        expect(CreateDQTTRNRequest).to receive(:call)
        call
      end
    end
  end

  context "decline recommendation" do
    let(:new_recommendation) { "decline" }

    describe "application declined email" do
      it "sends an email" do
        expect { call }.to have_enqueued_mail(
          TeacherMailer,
          :application_declined,
        )
      end
    end

    describe "DQT TRN request job" do
      it "doesn't create a DQT TRN request" do
        expect(CreateDQTTRNRequest).to_not receive(:call)
        call
      end
    end
  end

  context "request further information recommendataion" do
    let(:new_recommendation) { "request_further_information" }

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

    describe "application declined email" do
      it "doesn't send an email" do
        expect { call }.to_not have_enqueued_mail(
          TeacherMailer,
          :application_declined,
        )
      end
    end

    describe "DQT TRN request" do
      it "doesn't create a DQT TRN request" do
        expect(CreateDQTTRNRequest).to_not receive(:call)
        call
      end
    end
  end
end

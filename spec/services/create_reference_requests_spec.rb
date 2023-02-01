# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateReferenceRequests do
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff, :confirmed) }
  let(:work_history) { create(:work_history, :completed, application_form:) }

  subject(:call) do
    described_class.call(assessment:, user:, work_histories: [work_history])
  end

  describe "creating reference request" do
    subject(:reference_request) do
      ReferenceRequest.find_by(assessment:, work_history:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(reference_request.requested?).to be true
      end
    end
  end

  describe "updating application form state" do
    subject(:status) { application_form.status }

    it { is_expected.to eq("submitted") }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("waiting_on") }
    end
  end

  describe "sending referee email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(RefereeMailer, :reference_requested)
    end
  end

  describe "sending teacher email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :references_requested,
      )
    end
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end
end

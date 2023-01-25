# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateFurtherInformationRequest do
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff, :confirmed) }

  subject(:call) { described_class.call(assessment:, user:) }

  describe "creating further information request" do
    subject(:further_information_request) do
      FurtherInformationRequest.find_by(assessment:)
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(further_information_request.requested?).to be true
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

  describe "sending application received email" do
    it "queues an email job" do
      expect { call }.to have_enqueued_mail(
        TeacherMailer,
        :further_information_requested,
      )
    end
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(:requestable_requested)
  end
end

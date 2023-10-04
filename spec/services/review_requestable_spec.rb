# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewRequestable do
  let(:requestable) { create(:further_information_request, :received) }
  let(:user) { create(:staff) }
  let(:passed) { true }
  let(:failure_assessor_note) { "Note" }

  subject(:call) do
    described_class.call(requestable:, user:, passed:, failure_assessor_note:)
  end

  describe "requestable passed" do
    subject { requestable.passed }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be true }
    end
  end

  describe "requestable failure_assessor_note" do
    subject { requestable.failure_assessor_note }

    it { is_expected.to be_blank }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("Note") }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_reviewed,
      creator: user,
      requestable:,
    )
  end
end

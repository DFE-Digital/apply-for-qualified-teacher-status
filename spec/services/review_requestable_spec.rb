# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewRequestable do
  let(:requestable) { create(:further_information_request, :received) }
  let(:user) { create(:staff) }
  let(:passed) { true }
  let(:note) { "Note" }

  subject(:call) { described_class.call(requestable:, user:, passed:, note:) }

  describe "requestable review decision" do
    subject { requestable.review_passed }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be true }
    end
  end

  describe "requestable review note" do
    subject { requestable.review_note }

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
      old_value: "not_started",
      new_value: "accepted",
    )
  end
end

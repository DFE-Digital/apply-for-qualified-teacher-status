# frozen_string_literal: true

require "rails_helper"

RSpec.describe VerifyRequestable do
  let(:requestable) { create(:professional_standing_request, :received) }
  let(:user) { create(:staff) }
  let(:passed) { true }
  let(:note) { "Note" }

  subject(:call) { described_class.call(requestable:, user:, passed:, note:) }

  describe "requestable verify decision" do
    subject { requestable.verify_passed }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be true }
    end
  end

  describe "requestable verify note" do
    subject { requestable.verify_note }

    it { is_expected.to be_blank }

    context "after calling the service" do
      before { call }

      it { is_expected.to eq("Note") }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_verified,
      creator: user,
      requestable:,
    )
  end
end

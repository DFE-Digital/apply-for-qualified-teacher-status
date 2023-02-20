# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewRequestable do
  let(:requestable) { create(:further_information_request) }
  let(:user) { create(:staff) }
  let(:passed) { true }

  subject(:call) { described_class.call(requestable:, user:, passed:) }

  describe "requestable passed" do
    subject { requestable.passed }

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to be true }
    end
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_assessed,
      creator: user,
      requestable:,
    )
  end
end

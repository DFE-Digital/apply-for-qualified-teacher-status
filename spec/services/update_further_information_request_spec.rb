# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateFurtherInformationRequest do
  let(:further_information_request) { create(:further_information_request) }
  let(:user) { create(:staff) }
  let(:params) { { passed: true } }

  subject(:call) do
    described_class.call(further_information_request:, user:, params:)
  end

  describe "further information request attributes" do
    subject(:passed) { further_information_request.passed }

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
      requestable: further_information_request,
    )
  end
end

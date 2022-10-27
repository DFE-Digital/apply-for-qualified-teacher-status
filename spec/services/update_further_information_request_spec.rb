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

  describe "record timeline event" do
    subject(:timeline_event) do
      TimelineEvent.further_information_request_assessed.find_by(
        further_information_request:,
      )
    end

    it { is_expected.to be_nil }

    context "after calling the service" do
      before { call }

      it { is_expected.to_not be_nil }

      it "sets the attributes correctly" do
        expect(timeline_event.creator).to eq(user)
        expect(timeline_event.further_information_request).to eq(
          further_information_request,
        )
      end
    end
  end
end

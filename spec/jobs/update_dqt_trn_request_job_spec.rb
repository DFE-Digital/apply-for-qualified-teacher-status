# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateDQTTRNRequestJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(dqt_trn_request) }

    let(:dqt_trn_request) { create(:dqt_trn_request) }

    context "with an unsuccessful update" do
      before { expect(UpdateDQTTRNRequest).to receive(:call) }

      it "schedules a retry" do
        expect { perform }.to raise_error(UpdateDQTTRNRequestJob::StillPending)
      end
    end

    context "with a successful update" do
      before do
        expect(DQT::Client::ReadTRNRequest).to receive(:call).and_return(
          { trn: "abcdef" },
        )
      end

      it "runs without an error" do
        expect { perform }.to_not raise_error
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateDQTTRNRequest do
  let(:teacher) { create(:teacher) }
  let(:request_id) { SecureRandom.uuid }
  let(:application_form) { create(:application_form, teacher:) }

  subject(:call) { described_class.call(request_id:, application_form:) }

  context "with a successful response" do
    before do
      allow(DQT::Client::CreateTRNRequest).to receive(:call).and_return(
        { trn: "abcdef" },
      )
    end

    it "creates a DQTTRNRequest" do
      expect { call }.to change(DQTTRNRequest, :count).by(1)
    end

    it "marks the request as complete" do
      call
      expect(DQTTRNRequest.first.complete?).to be true
    end

    it "sets the teacher TRN" do
      expect { call }.to change(teacher, :trn).from(nil).to("abcdef")
    end

    it "doesn't schedule an update job" do
      expect { call }.to_not have_enqueued_job(UpdateDQTTRNRequestJob)
    end
  end

  context "with a failure response" do
    before do
      allow(DQT::Client::CreateTRNRequest).to receive(:call).and_raise(
        Faraday::BadRequestError.new(StandardError.new),
      )
    end

    let(:call_rescue_exception) do
      call
    rescue StandardError
      Faraday::BadRequestError
    end

    it "creates a DQTTRNRequest" do
      expect { call_rescue_exception }.to change(DQTTRNRequest, :count).by(1)
      expect(DQTTRNRequest.first.initial?).to be true
    end

    it "doesn't set the teacher TRN" do
      expect { call_rescue_exception }.to_not change(teacher, :trn)
    end

    it "doesn't schedule an update job" do
      expect { call_rescue_exception }.to_not have_enqueued_job(
        UpdateDQTTRNRequestJob,
      )
    end
  end

  context "with an existing DQT TRN request" do
    let!(:dqt_trn_request) do
      create(:dqt_trn_request, request_id:, application_form:)
    end

    before do
      expect(DQT::Client::ReadTRNRequest).to receive(:call).and_return(
        { trn: "abcdef" },
      )
    end

    it "doesn't create another DQTTRNRequest" do
      expect { call }.to_not change(DQTTRNRequest, :count)
    end

    it "marks the request as complete" do
      call
      expect(dqt_trn_request.reload.complete?).to be true
    end
  end
end

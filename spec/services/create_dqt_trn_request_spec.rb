# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateDQTTRNRequest do
  let(:teacher) { create(:teacher) }
  let(:application_form) { create(:application_form, teacher:) }

  subject(:call) { described_class.call(application_form:) }

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
  end

  context "with a failure response" do
    before do
      allow(DQT::Client::CreateTRNRequest).to receive(:call).and_raise(
        Faraday::BadRequestError.new(StandardError.new),
      )
    end

    it "creates a DQTTRNRequest" do
      expect { call }.to change(DQTTRNRequest, :count).by(1)
    end

    it "marks the request as pending" do
      call
      expect(DQTTRNRequest.first.pending?).to be true
    end

    it "doesn't set the teacher TRN" do
      expect { call }.to_not change(teacher, :trn)
    end
  end
end

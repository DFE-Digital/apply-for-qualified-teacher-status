# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateDQTTRNRequest do
  let(:teacher) { create(:teacher) }
  let(:dqt_trn_request) do
    create(
      :dqt_trn_request,
      application_form: create(:application_form, teacher:),
    )
  end

  subject(:call) { described_class.call(dqt_trn_request:) }

  context "with a successful response" do
    before do
      allow(DQT::Client::ReadTRNRequest).to receive(:call).and_return(
        { trn: "abcdef" },
      )
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
      allow(DQT::Client::ReadTRNRequest).to receive(:call).and_raise(
        Faraday::BadRequestError.new(StandardError.new),
      )
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

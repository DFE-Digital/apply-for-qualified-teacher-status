# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestablesJob, type: :job do
  shared_examples "a job which expires requestables" do |class_name, factory_name|
    describe "#perform" do
      subject { described_class.new.perform(class_name) }

      let!(:requested_requestable) { create(factory_name, :requested) }
      let!(:received_requestable) { create(factory_name, :received) }
      let!(:expired_requestable) { create(factory_name, :expired) }

      it "enqueues a job for each 'requested' #{class_name}s" do
        expect(ExpireRequestableJob).to receive(:perform_later).with(
          requestable: requested_requestable,
        )
        subject
      end

      it "doesn't enqueue a job for 'received' #{class_name}s" do
        expect(ExpireRequestableJob).not_to receive(:perform_later).with(
          requestable: received_requestable,
        )
        subject
      end

      it "doesn't enqueue a job for 'expired' #{class_name}s" do
        expect(ExpireRequestableJob).not_to receive(:perform_later).with(
          requestable: expired_requestable,
        )
        subject
      end
    end
  end

  context "with further information requests" do
    it_behaves_like "a job which expires requestables",
                    "FurtherInformationRequest",
                    :further_information_request
  end

  context "with professional standing requests" do
    it_behaves_like "a job which expires requestables",
                    "ProfessionalStandingRequest",
                    :professional_standing_request
  end

  context "with reference requests" do
    it_behaves_like "a job which expires requestables",
                    "ReferenceRequest",
                    :reference_request
  end
end

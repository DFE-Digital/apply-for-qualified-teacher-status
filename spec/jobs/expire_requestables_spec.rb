# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestablesJob, type: :job do
  shared_examples "a job which expires requestables" do |class_name, factory_name|
    describe "#perform" do
      subject(:perform) { described_class.new.perform(class_name) }

      let!(:requested_requestable) { create(factory_name, :requested) }
      let!(:received_requestable) { create(factory_name, :received) }
      let!(:expired_requestable) { create(factory_name, :expired) }

      it "enqueues a job for each 'requested' #{class_name}s" do
        expect { perform }.to have_enqueued_job(ExpireRequestableJob).with(
          requested_requestable,
        )
      end

      it "doesn't enqueue a job for 'received' #{class_name}s" do
        expect { perform }.to_not have_enqueued_job(ExpireRequestableJob).with(
          received_requestable,
        )
      end

      it "doesn't enqueue a job for 'expired' #{class_name}s" do
        expect { perform }.to_not have_enqueued_job(ExpireRequestableJob).with(
          expired_requestable,
        )
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

# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireRequestablesJob, type: :job do
  shared_examples "a job which expires requestables" do |class_name, factory_name|
    describe "#perform" do
      subject(:perform) { described_class.new.perform(class_name) }

      let!(:requested_requestable) do
        create(:"requested_#{factory_name}", requested_at: 1.year.ago)
      end
      let!(:received_requestable) { create(:"received_#{factory_name}") }
      let!(:expired_requestable) do
        create(:"requested_#{factory_name}", :expired)
      end

      it "enqueues a job for each requested #{class_name}s" do
        expect(ExpireRequestable).to receive(:call).with(
          requestable: requested_requestable,
          user: "Expirer",
        )
        perform
      end

      it "doesn't enqueue a job for received #{class_name}s" do
        expect(ExpireRequestable).to_not receive(:call).with(
          requestable: received_requestable,
          user: "Expirer",
        )
        perform
      end

      it "doesn't enqueue a job for expired #{class_name}s" do
        expect(ExpireRequestable).to_not receive(:call).with(
          requestable: expired_requestable,
          user: "Expirer",
        )
        perform
      end
    end
  end

  context "with consent requests" do
    it_behaves_like "a job which expires requestables",
                    "ConsentRequest",
                    :consent_request
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

  context "with qualification requests" do
    it_behaves_like "a job which expires requestables",
                    "QualificationRequest",
                    :qualification_request
  end

  context "with reference requests" do
    it_behaves_like "a job which expires requestables",
                    "ReferenceRequest",
                    :reference_request
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderEmailsJob do
  shared_examples "a job which sends reminders" do |class_name, factory_name|
    describe "#perform" do
      subject(:perform) { described_class.new.perform(class_name) }

      let!(:requested_remindable) { create(factory_name, :requested) }
      let!(:received_remindable) { create(factory_name, :received) }
      let!(:expired_remindable) { create(factory_name, :expired) }

      it "enqueues a job for each 'requested' #{class_name}s" do
        expect { perform }.to have_enqueued_job(SendReminderEmailJob).with(
          requested_remindable,
        )
      end

      it "doesn't enqueue a job for 'received' #{class_name}s" do
        expect { perform }.to_not have_enqueued_job(SendReminderEmailJob).with(
          received_remindable,
        )
      end

      it "doesn't enqueue a job for 'expired' #{class_name}s" do
        expect { perform }.to_not have_enqueued_job(SendReminderEmailJob).with(
          expired_remindable,
        )
      end
    end
  end

  context "with further information requests" do
    it_behaves_like "a job which sends reminders",
                    "FurtherInformationRequest",
                    :further_information_request
  end

  context "with reference requests" do
    it_behaves_like "a job which sends reminders",
                    "ReferenceRequest",
                    :reference_request
  end
end

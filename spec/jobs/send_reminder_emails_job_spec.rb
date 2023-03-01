# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderEmailsJob do
  shared_examples "a job which sends reminders" do |class_name, factory_name, remindable_trait, not_remindable_trait|
    describe "#perform" do
      subject(:perform) { described_class.new.perform(class_name) }

      let!(:remindable) { create(factory_name, remindable_trait) }
      let!(:not_remindable) { create(factory_name, not_remindable_trait) }

      it "enqueues a job for each 'remindable' #{class_name}s" do
        expect { perform }.to have_enqueued_job(SendReminderEmailJob).with(
          remindable,
        )
      end

      it "doesn't enqueue a job for 'not remindable' #{class_name}s" do
        expect { perform }.to_not have_enqueued_job(SendReminderEmailJob).with(
          not_remindable,
        )
      end
    end
  end

  context "with further information requests" do
    it_behaves_like "a job which sends reminders",
                    "ApplicationForm",
                    :application_form,
                    :draft,
                    :submitted
  end

  context "with further information requests" do
    it_behaves_like "a job which sends reminders",
                    "FurtherInformationRequest",
                    :further_information_request,
                    :requested,
                    :received
  end

  context "with reference requests" do
    it_behaves_like "a job which sends reminders",
                    "ReferenceRequest",
                    :reference_request,
                    :requested,
                    :received
  end
end

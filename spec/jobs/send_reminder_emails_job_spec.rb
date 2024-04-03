# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderEmailsJob do
  shared_examples "a job which sends reminders" do |class_name, remindable_factory_name, not_remindable_factory_name|
    describe "#perform" do
      subject(:perform) { described_class.new.perform(class_name) }

      let!(:remindable) do
        create(remindable_factory_name, created_at: 6.months.ago)
      end
      let!(:not_remindable) do
        create(not_remindable_factory_name, created_at: 6.months.ago)
      end

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

  context "with application forms" do
    it_behaves_like "a job which sends reminders",
                    "ApplicationForm",
                    :draft_application_form,
                    :submitted_application_form
  end

  context "with further information requests" do
    it_behaves_like "a job which sends reminders",
                    "FurtherInformationRequest",
                    :requested_further_information_request,
                    :received_further_information_request
  end

  context "with reference requests" do
    it_behaves_like "a job which sends reminders",
                    "ReferenceRequest",
                    :requested_reference_request,
                    :received_reference_request
  end
end

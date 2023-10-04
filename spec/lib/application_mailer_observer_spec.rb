# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailerObserver do
  shared_examples "observes mail" do
    subject(:delivered_email) { described_class.delivered_email(message) }

    it "records a timeline event" do
      expect { delivered_email }.to have_recorded_timeline_event(
        :email_sent,
        application_form:,
      )
    end

    it "is called when an email is sent" do
      expect(ApplicationMailerObserver).to receive(:delivered_email).with(
        message,
      )
      message.deliver_now
    end
  end

  context "with a referee mailer" do
    let(:reference_request) { create(:reference_request, :requested) }
    let(:application_form) { reference_request.assessment.application_form }
    let(:message) { RefereeMailer.with(reference_request:).reference_requested }

    include_examples "observes mail"
  end

  context "with a teacher mailer" do
    let(:application_form) { create(:application_form) }
    let(:message) do
      TeacherMailer.with(teacher: application_form.teacher).application_received
    end

    include_examples "observes mail"
  end

  context "with a teaching authority mailer" do
    let(:region) do
      create(:region, teaching_authority_emails: ["authority@region.com"])
    end
    let(:application_form) do
      create(
        :application_form,
        :with_personal_information,
        :with_completed_qualification,
        region:,
      )
    end
    let(:message) do
      TeachingAuthorityMailer.with(application_form:).application_submitted
    end

    include_examples "observes mail"
  end
end

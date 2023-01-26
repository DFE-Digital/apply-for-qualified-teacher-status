# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailerObserver do
  let(:teacher) { create(:teacher) }
  let!(:application_form) { create(:application_form, teacher:) }
  let(:message) { TeacherMailer.with(teacher:).application_received }

  subject(:delivered_email) { described_class.delivered_email(message) }

  it "records a timeline event" do
    expect { delivered_email }.to have_recorded_timeline_event(
      :email_sent,
      application_form:,
      mailer_class_name: "TeacherMailer",
      mailer_action_name: "application_received",
      message_subject:
        "We’ve received your application for qualified teacher status (QTS)",
    )
  end

  it "is called when an email is sent" do
    application_form = create(:application_form, :submitted)
    message =
      TeacherMailer.with(teacher: application_form.teacher).application_received

    expect(ApplicationMailerObserver).to receive(:delivered_email).with(message)

    message.deliver_now
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationMailerObserver do
  let(:teacher) { create(:teacher) }
  let!(:application_form) { create(:application_form, teacher:) }
  let(:message) { TeacherMailer.with(teacher:).application_received }

  subject(:delivered_email) { described_class.delivered_email(message) }

  it "creates a timeline event" do
    expect { delivered_email }.to change(TimelineEvent, :count).by(1)
  end

  it "sets the attributes" do
    timeline_event = delivered_email

    expect(timeline_event.event_type).to eq("email_sent")
    expect(timeline_event.application_form).to eq(application_form)
    expect(timeline_event.mailer_class_name).to eq("TeacherMailer")
    expect(timeline_event.mailer_action_name).to eq("application_received")
    expect(timeline_event.message_subject).to eq(
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

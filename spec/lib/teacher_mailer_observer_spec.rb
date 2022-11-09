# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherMailerObserver do
  let(:teacher) { create(:teacher, :confirmed) }
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
    expect(timeline_event.mailer_action_name).to eq("application_received")
  end
end

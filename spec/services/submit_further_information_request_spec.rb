# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmitFurtherInformationRequest do
  let(:application_form) { create(:application_form, :submitted) }
  let(:further_information_request) do
    create(
      :further_information_request,
      :requested,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:user) { application_form.teacher }

  subject(:call) { described_class.call(further_information_request:, user:) }

  context "with an already received further information request" do
    before { further_information_request.received! }

    it "raises an error" do
      expect { call }.to raise_error(
        SubmitFurtherInformationRequest::AlreadySubmitted,
      )
    end
  end

  it "changes the further information request state to received" do
    expect { call }.to change(further_information_request, :received?).from(
      false,
    ).to(true)
  end

  it "changes the application form state to received" do
    expect { call }.to change(application_form, :received?).from(false).to(true)
  end

  it "changes the further information request received at" do
    freeze_time do
      expect { call }.to change(further_information_request, :received_at).from(
        nil,
      ).to(Time.current)
    end
  end

  it "sends an email" do
    expect { call }.to have_enqueued_mail(
      TeacherMailer,
      :further_information_received,
    )
  end

  it "records a requestable received timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_received,
      requestable: further_information_request,
    )
  end

  it "records a state changed timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :state_changed,
      creator: user,
      old_state: "submitted",
      new_state: "received",
    )
  end
end

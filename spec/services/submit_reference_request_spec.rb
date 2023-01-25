# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmitReferenceRequest do
  let(:application_form) { create(:application_form, :submitted) }
  let(:reference_request) do
    create(
      :reference_request,
      :requested,
      :receivable,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:user) { "John Smith" }

  subject(:call) { described_class.call(reference_request:, user:) }

  context "with an already received reference request" do
    before { reference_request.received! }

    it "raises an error" do
      expect { call }.to raise_error(SubmitReferenceRequest::AlreadySubmitted)
    end
  end

  it "changes the reference request state to received" do
    expect { call }.to change(reference_request, :received?).from(false).to(
      true,
    )
  end

  it "changes the application form state to received" do
    expect { call }.to change(application_form, :received?).from(false).to(true)
  end

  it "changes the reference request received at" do
    freeze_time do
      expect { call }.to change(reference_request, :received_at).from(nil).to(
        Time.current,
      )
    end
  end

  it "records a requestable received timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_received,
      requestable: reference_request,
    )
  end

  it "records a state changed timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :state_changed,
      creator_name: user,
      old_state: "submitted",
      new_state: "received",
    )
  end
end

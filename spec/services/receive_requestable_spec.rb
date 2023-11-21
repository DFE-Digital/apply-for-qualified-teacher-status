# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReceiveRequestable do
  let(:application_form) { create(:application_form, :submitted) }
  let(:requestable) do
    create(
      :qualification_request,
      :requested,
      :receivable,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:user) { "John Smith" }

  subject(:call) { described_class.call(requestable:, user:) }

  context "with an already received requestable" do
    before { requestable.received! }

    it "raises an error" do
      expect { call }.to raise_error(ReceiveRequestable::AlreadyReceived)
    end
  end

  it "changes the requestable state to received" do
    expect { call }.to change(requestable, :received?).from(false).to(true)
  end

  it "changes the application form status" do
    expect { call }.to change { application_form.reload.statuses }.to(
      %w[received_qualification],
    )
  end

  it "changes the requestable received at" do
    freeze_time do
      expect { call }.to change(requestable, :received_at).from(nil).to(
        Time.current,
      )
    end
  end

  it "records a requestable received timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_received,
      requestable:,
    )
  end
end

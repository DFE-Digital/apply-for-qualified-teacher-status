# frozen_string_literal: true

require "rails_helper"

RSpec.describe UnreceiveRequestable do
  subject(:call) { described_class.call(requestable:, user:) }

  let(:application_form) do
    create(:application_form, :submitted, statuses: %w[received_ecctis])
  end
  let(:requestable) do
    create(
      :received_qualification_request,
      assessment: create(:assessment, application_form:),
    )
  end
  let!(:timeline_event) do
    create(
      :timeline_event,
      :requestable_received,
      requestable:,
      application_form:,
    )
  end
  let(:user) { "John Smith" }

  context "with an already not received requestable" do
    before { requestable.update!(received_at: nil) }

    it "raises an error" do
      expect { call }.to raise_error(UnreceiveRequestable::NotReceived)
    end
  end

  it "changes the requestable state from received" do
    expect { call }.to change(requestable, :received?).from(true).to(false)
  end

  it "changes the application form status" do
    expect { call }.to change { application_form.reload.statuses }.to(
      %w[waiting_on_ecctis],
    )
  end

  it "changes the requestable received at" do
    expect { call }.to change(requestable, :received_at).to(nil)
  end

  it "deletes the requestable received timeline event" do
    expect { call }.to change { TimelineEvent.requestable_received.count }.by(
      -1,
    )
    expect { timeline_event.reload }.to raise_error(
      ActiveRecord::RecordNotFound,
    )
  end
end

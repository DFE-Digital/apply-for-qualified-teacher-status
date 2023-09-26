# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestRequestable do
  let(:application_form) { create(:application_form, :submitted) }
  let(:requestable) do
    create(
      :qualification_request,
      assessment: create(:assessment, application_form:),
    )
  end
  let(:user) { "John Smith" }

  subject(:call) { described_class.call(requestable:, user:) }

  context "with an already requested requestable" do
    before { requestable.requested! }

    it "raises an error" do
      expect { call }.to raise_error(RequestRequestable::AlreadyRequested)
    end
  end

  it "changes the requestable state to requested" do
    expect { call }.to change(requestable, :requested?).from(false).to(true)
  end

  it "changes the requestable requested at" do
    freeze_time do
      expect { call }.to change(requestable, :requested_at).from(nil).to(
        Time.current,
      )
    end
  end

  it "records a requestable requested timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :requestable_requested,
      requestable:,
    )
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateTRSTRNRequest do
  subject(:call) { described_class.call(application_form:, user:) }

  let(:application_form) { create(:application_form, :submitted) }
  let(:user) { create(:staff) }

  it "creates a DQTTRNRequest" do
    expect { call }.to change(DQTTRNRequest, :count).by(1)
  end

  it "changes the status" do
    expect { call }.to change(application_form, :statuses).to(
      %w[awarded_pending_checks],
    )
  end

  it "schedules an update job" do
    expect { call }.to have_enqueued_job(UpdateTRSTRNRequestJob).with(
      DQTTRNRequest.first,
    )
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateDQTTRNRequest do
  let(:application_form) { create(:application_form) }

  subject(:call) { described_class.call(application_form:) }

  it "creates a DQTTRNRequest" do
    expect { call }.to change(DQTTRNRequest, :count).by(1)
  end

  it "schedules an update job" do
    expect { call }.to have_enqueued_job(UpdateDQTTRNRequestJob).with(
      DQTTRNRequest.first,
    )
  end
end

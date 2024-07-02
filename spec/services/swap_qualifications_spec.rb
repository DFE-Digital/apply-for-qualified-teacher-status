# frozen_string_literal: true

require "rails_helper"

RSpec.describe SwapQualifications do
  subject(:call) do
    described_class.call(
      teaching_qualification,
      degree_qualification,
      note:,
      user:,
    )
  end

  let(:application_form) { create(:application_form) }
  let!(:teaching_qualification) do
    create(:qualification, application_form:, created_at: Date.new(2020, 1, 1))
  end
  let!(:degree_qualification) do
    create(:qualification, application_form:, created_at: Date.new(2020, 1, 2))
  end
  let(:note) { "A note." }
  let(:user) { create(:staff) }

  it "swaps the first created_at" do
    expect { call }.to change(teaching_qualification, :created_at).to(
      Date.new(2020, 1, 2),
    )
  end

  it "swaps the second created_at" do
    expect { call }.to change(degree_qualification, :created_at).to(
      Date.new(2020, 1, 1),
    )
  end

  it "creates a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :note_created,
      creator: user,
    )
  end
end

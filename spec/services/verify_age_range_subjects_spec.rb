# frozen_string_literal: true

require "rails_helper"

RSpec.describe VerifyAgeRangeSubjects do
  let(:assessment) { create(:assessment) }
  let(:user) { create(:staff) }
  let(:age_range_min) { 8 }
  let(:age_range_max) { 11 }
  let(:age_range_note) { "A note." }
  let(:subjects) { %w[english_studies mathematics] }
  let(:subjects_note) { "A note." }

  subject(:call) do
    described_class.call(
      assessment:,
      user:,
      age_range_min:,
      age_range_max:,
      age_range_note:,
      subjects:,
      subjects_note:,
    )
  end

  it "sets the minimum age" do
    expect { call }.to change(assessment, :age_range_min).to(8)
  end

  it "sets the maximum age" do
    expect { call }.to change(assessment, :age_range_max).to(11)
  end

  it "sets the age note" do
    expect { call }.to change(assessment, :age_range_note).to("A note.")
  end

  it "sets the subjects" do
    expect { call }.to change(assessment, :subjects).to(
      %w[english_studies mathematics],
    )
  end

  it "sets the subjects note" do
    expect { call }.to change(assessment, :subjects_note).to("A note.")
  end

  it "records a timeline event" do
    expect { call }.to have_recorded_timeline_event(
      :age_range_subjects_verified,
      creator: user,
    )
  end
end

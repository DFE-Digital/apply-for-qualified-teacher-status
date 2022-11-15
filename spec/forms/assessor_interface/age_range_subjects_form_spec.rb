# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AgeRangeSubjectsForm, type: :model do
  let(:assessment) { create(:assessment) }
  let(:user) { create(:staff, :confirmed) }
  let(:attributes) { {} }

  subject(:form) { described_class.new(assessment:, user:, **attributes) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:age_range_min) }
    it do
      is_expected.to validate_numericality_of(
        :age_range_min,
      ).only_integer.is_greater_than_or_equal_to(0)
    end

    it { is_expected.to validate_presence_of(:age_range_max) }

    context "when minimum is set" do
      let(:attributes) { { age_range_min: "7" } }
      it do
        is_expected.to validate_numericality_of(
          :age_range_max,
        ).only_integer.is_greater_than_or_equal_to(7)
      end
    end

    it { is_expected.to_not validate_presence_of(:age_range_note) }

    it { is_expected.to validate_presence_of(:subject_1) }
    it { is_expected.to_not validate_presence_of(:subject_2) }
    it { is_expected.to_not validate_presence_of(:subject_3) }
    it { is_expected.to_not validate_presence_of(:subjects_note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes and no note" do
      let(:attributes) do
        { age_range_min: "7", age_range_max: "11", subject_1: "Subject" }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment.age_range_min).to eq(7)
        expect(assessment.age_range_max).to eq(11)
        expect(assessment.age_range_note).to be_blank

        expect(assessment.subjects).to eq(%w[Subject])
        expect(assessment.subjects_note).to be_blank
      end

      it "creates a timeline event" do
        timeline_events = TimelineEvent.age_range_subjects_verified
        expect { save }.to change(timeline_events, :count).by(1)
        expect(timeline_events.last.assessment).to eq(assessment)
      end
    end

    describe "with valid attributes and a note" do
      let(:attributes) do
        {
          age_range_min: "7",
          age_range_max: "11",
          age_range_note: "A note.",
          subject_1: "Subject",
          subjects_note: "Another note.",
        }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment.age_range_note).to eq("A note.")
        expect(assessment.subjects_note).to eq("Another note.")
      end

      it "creates a timeline event" do
        timeline_events = TimelineEvent.age_range_subjects_verified
        expect { save }.to change(timeline_events, :count).by(1)
        expect(timeline_events.last.assessment).to eq(assessment)
      end
    end
  end
end

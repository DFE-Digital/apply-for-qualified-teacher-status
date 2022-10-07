# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AgeRangeSubjectsForm, type: :model do
  let(:assessment_section) { create(:assessment_section, :age_range_subjects) }
  let(:user) { create(:staff, :confirmed) }
  let(:attributes) { {} }

  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
    )
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment_section) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to allow_values(true, false).for(:passed) }

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
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:assessment) { assessment_section.assessment }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes and no note" do
      let(:attributes) do
        { passed: true, age_range_min: "7", age_range_max: "11" }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment.age_range_min).to eq(7)
        expect(assessment.age_range_max).to eq(11)
        expect(assessment.age_range_note).to be_nil
      end
    end

    describe "with valid attributes and a note" do
      let(:attributes) do
        {
          passed: true,
          age_range_min: "7",
          age_range_max: "11",
          age_range_note: "A note.",
        }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment.age_range_note.text).to eq("A note.")
      end
    end
  end
end

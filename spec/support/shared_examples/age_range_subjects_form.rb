# frozen_string_literal: true

RSpec.shared_examples_for "an age range subjects form" do
  it { is_expected.to validate_presence_of(:age_range_min) }
  it { is_expected.to validate_presence_of(:age_range_max) }

  describe "validations" do
    let(:age_range_subjects_attributes) do
      {
        age_range_min: "5",
        age_range_max: "16",
        subject_1: "Subject",
        subject_1_raw: "Subject",
      }
    end

    context "with a minimum too low" do
      before { age_range_subjects_attributes[:age_range_min] = "-1" }

      it { is_expected.to be_invalid }
    end

    context "with a minimum between 0 and 19" do
      before { age_range_subjects_attributes[:age_range_min] = "8" }

      it { is_expected.to be_valid }
    end

    context "with a maximum lower than the minimum" do
      before { age_range_subjects_attributes[:age_range_max] = "4" }

      it { is_expected.to be_invalid }
    end

    context "with a maximum greater than min but below 20" do
      before { age_range_subjects_attributes[:age_range_max] = "19" }

      it { is_expected.to be_valid }
    end

    context "with a maximum too high" do
      before { age_range_subjects_attributes[:age_range_max] = "20" }

      it { is_expected.to be_invalid }
    end

    it { is_expected.not_to validate_presence_of(:age_range_note) }

    it { is_expected.to validate_presence_of(:subject_1) }
    it { is_expected.to validate_presence_of(:subject_1_raw) }
    it { is_expected.not_to validate_presence_of(:subject_2) }
    it { is_expected.not_to validate_presence_of(:subject_3) }
    it { is_expected.not_to validate_presence_of(:subjects_note) }
  end

  describe "#save" do
    subject(:save) { form.save }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes and no note" do
      let(:age_range_subjects_attributes) do
        {
          age_range_min: "7",
          age_range_max: "11",
          subject_1: "Subject",
          subject_1_raw: "Subject",
        }
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

      it "records a timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :age_range_subjects_verified,
          assessment:,
        )
      end
    end

    describe "with valid attributes and a note" do
      let(:age_range_subjects_attributes) do
        {
          age_range_min: "7",
          age_range_max: "11",
          age_range_note: "A note.",
          subject_1: "Subject",
          subject_1_raw: "Subject",
          subjects_note: "Another note.",
        }
      end

      it { is_expected.to be true }

      it "sets the attributes" do
        save # rubocop:disable Rails/SaveBang

        expect(assessment.age_range_note).to eq("A note.")
        expect(assessment.subjects_note).to eq("Another note.")
      end

      it "records a timeline event" do
        expect { save }.to have_recorded_timeline_event(
          :age_range_subjects_verified,
          assessment:,
        )
      end
    end
  end
end

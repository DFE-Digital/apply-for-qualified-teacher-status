require "spec_helper"

RSpec.describe TeacherInterface::PartOfUniversityDegreeForm, type: :model do
  subject(:part_of_university_degree_form) do
    described_class.new(qualification:, part_of_university_degree:)
  end

  let(:qualification) { build(:qualification) }
  let(:part_of_university_degree) { nil }

  it { is_expected.to validate_presence_of(:qualification) }

  describe "#valid?" do
    subject(:valid?) { part_of_university_degree_form.valid? }

    context "with a blank value" do
      let(:part_of_university_degree) { "" }

      it { is_expected.to be true }
    end

    context "with a true value" do
      let(:part_of_university_degree) { "true" }

      it { is_expected.to be true }
    end

    context "with a false value" do
      let(:part_of_university_degree) { "false" }

      it { is_expected.to be true }
    end
  end

  describe "#save" do
    subject(:part_of_university_degree_value) do
      qualification.part_of_university_degree
    end

    before { part_of_university_degree_form.save }

    context "with a blank value" do
      let(:part_of_university_degree) { "" }

      it { is_expected.to be_nil }
    end

    context "with a true value" do
      let(:part_of_university_degree) { "true" }

      it { is_expected.to be true }
    end

    context "with a false value" do
      let(:part_of_university_degree) { "false" }

      it { is_expected.to be false }
    end
  end
end

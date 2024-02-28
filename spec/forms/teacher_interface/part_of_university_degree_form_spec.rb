require "rails_helper"

RSpec.describe TeacherInterface::PartOfUniversityDegreeForm, type: :model do
  let(:application_form) { create(:application_form) }
  let(:qualification) { build(:qualification, application_form:) }

  subject(:form) do
    described_class.new(qualification:, part_of_university_degree:)
  end

  describe "validations" do
    let(:part_of_university_degree) { "" }

    it { is_expected.to validate_presence_of(:qualification) }
    it do
      is_expected.to allow_values(true, false).for(:part_of_university_degree)
    end
  end

  describe "#save" do
    let(:part_of_university_degree) { "true" }

    before { form.save(validate: true) }

    it "saves the qualification" do
      expect(qualification.part_of_university_degree).to eq(true)
    end

    it "saves the application form" do
      expect(application_form.teaching_qualification_part_of_degree).to eq(true)
    end
  end
end

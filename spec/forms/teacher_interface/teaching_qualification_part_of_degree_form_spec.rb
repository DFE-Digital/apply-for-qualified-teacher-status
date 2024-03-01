require "rails_helper"

RSpec.describe TeacherInterface::TeachingQualificationPartOfDegreeForm,
               type: :model do
  let(:application_form) { create(:application_form) }

  subject(:form) do
    described_class.new(
      application_form:,
      teaching_qualification_part_of_degree:,
    )
  end

  describe "validations" do
    let(:teaching_qualification_part_of_degree) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it do
      is_expected.to allow_values(true, false).for(
        :teaching_qualification_part_of_degree,
      )
    end
  end

  describe "#save" do
    let(:teaching_qualification_part_of_degree) { "true" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.teaching_qualification_part_of_degree).to eq(true)
    end
  end
end

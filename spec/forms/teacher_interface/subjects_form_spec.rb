require "rails_helper"

RSpec.describe TeacherInterface::SubjectsForm, type: :model do
  subject(:form) do
    described_class.new(application_form:, subject_1:, subject_2:, subject_3:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:subject_1) { "" }
    let(:subject_2) { "" }
    let(:subject_3) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:subject_1) }
    it { is_expected.not_to validate_presence_of(:subject_2) }
    it { is_expected.not_to validate_presence_of(:subject_3) }
  end

  describe "#save" do
    let(:subject_1) { "Subject 1" }
    let(:subject_2) { "Subject 2" }
    let(:subject_3) { "" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.subjects).to eq(["Subject 1", "Subject 2"])
    end
  end
end

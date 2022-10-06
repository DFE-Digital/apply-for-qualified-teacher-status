require "rails_helper"

RSpec.describe TeacherInterface::HasWorkHistoryForm, type: :model do
  let(:application_form) { build(:application_form) }

  subject(:form) { described_class.new(application_form:, has_work_history:) }

  describe "validations" do
    let(:has_work_history) { "" }

    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to allow_values(true, false).for(:has_work_history) }
  end

  describe "#save" do
    let(:has_work_history) { "true" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.has_work_history).to eq(true)
    end
  end
end

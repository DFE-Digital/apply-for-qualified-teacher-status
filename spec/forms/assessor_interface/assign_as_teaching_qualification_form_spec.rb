# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssignAsTeachingQualificationForm,
               type: :model do
  subject(:form) do
    described_class.new(qualification: new_teaching_qualification, user:)
  end

  let(:current_teaching_qualification) do
    create :qualification,
           application_form: new_teaching_qualification.application_form,
           created_at: new_teaching_qualification.created_at - 1.hour
  end

  let(:new_teaching_qualification) { create(:qualification) }
  let(:user) { create(:staff) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:qualification) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "#save" do
    subject(:save) { form.save }

    it "calls the assign new teaching qualification service" do
      expect(AssignNewTeachingQualification).to receive(:call).with(
        current_teaching_qualification:,
        new_teaching_qualification:,
        user:,
      )
      expect(save).to be true
    end
  end
end

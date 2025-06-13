# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherInterface::OtherEnglandWorkHistoryMeetsCriteriaForm,
               type: :model do
  subject(:form) do
    described_class.new(application_form:, has_other_england_work_history:)
  end

  let(:application_form) { build(:application_form) }

  describe "validations" do
    let(:has_other_england_work_history) { "" }

    it { is_expected.to validate_presence_of(:application_form) }

    it do
      expect(subject).to allow_values(true, false).for(
        :has_other_england_work_history,
      )
    end
  end

  describe "#save" do
    let(:has_other_england_work_history) { "true" }

    before { form.save(validate: true) }

    it "saves the application form" do
      expect(application_form.has_other_england_work_history).to be(true)
    end
  end
end

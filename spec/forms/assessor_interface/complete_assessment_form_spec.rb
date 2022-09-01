require "rails_helper"

RSpec.describe AssessorInterface::CompleteAssessmentForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:application_form) }
    it { is_expected.to validate_presence_of(:staff) }
    it { is_expected.to validate_presence_of(:new_state) }
    it do
      is_expected.to validate_inclusion_of(:new_state).in_array(
        %w[awarded declined]
      )
    end
  end

  let(:application_form) { build(:application_form, :submitted) }
  let(:staff) { create(:staff, :confirmed) }
  let(:new_state) { "awarded" }

  describe "#save!" do
    let(:form) { described_class.new(application_form:, staff:, new_state:) }

    before { form.save! }

    it "saves the application form" do
      expect(application_form.awarded?).to be true
    end
  end
end

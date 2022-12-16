# frozen_string_literal: true

require "rails_helper"

RSpec.describe EligibilityInterface::WorkExperienceForm, type: :model do
  let(:eligibility_check) { create(:eligibility_check) }
  let(:work_experience) { nil }

  subject(:form) { described_class.new(eligibility_check:, work_experience:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:eligibility_check) }
    it { is_expected.to validate_presence_of(:work_experience) }
    it do
      is_expected.to validate_inclusion_of(:work_experience).in_array(
        %w[under_9_months between_9_and_20_months over_20_months],
      )
    end
  end

  describe "#save" do
    subject(:save) { form.save }

    let(:work_experience) { "under_9_months" }

    it "saves the eligibility check" do
      expect { save }.to change { eligibility_check.work_experience }.to(
        "under_9_months",
      )
    end
  end
end

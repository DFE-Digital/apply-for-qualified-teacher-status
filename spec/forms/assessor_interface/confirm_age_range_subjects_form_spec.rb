# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ConfirmAgeRangeSubjectsForm, type: :model do
  subject(:form) do
    described_class.new(assessment:, user:, **age_range_subjects_attributes)
  end

  let(:assessment) { create(:assessment) }
  let(:user) { create(:staff) }
  let(:age_range_subjects_attributes) { {} }

  it_behaves_like "an age range subjects form"

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:user) }
  end
end

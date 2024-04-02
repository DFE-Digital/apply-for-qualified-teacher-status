# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::ConfirmAgeRangeSubjectsForm, type: :model do
  let(:assessment) { create(:assessment) }
  let(:user) { create(:staff) }
  let(:age_range_subjects_attributes) { {} }

  subject(:form) do
    described_class.new(assessment:, user:, **age_range_subjects_attributes)
  end

  it_behaves_like "an age range subjects form"

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "#save" do
    subject(:save) { form.save }

    describe "when invalid attributes" do
      it { is_expected.to be false }
    end
  end
end

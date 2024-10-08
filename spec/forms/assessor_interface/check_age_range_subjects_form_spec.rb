# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::CheckAgeRangeSubjectsForm, type: :model do
  subject(:form) do
    described_class.for_assessment_section(assessment_section).new(
      assessment_section:,
      user:,
      **attributes,
      **age_range_subjects_attributes,
    )
  end

  let(:assessment_section) { create(:assessment_section, :age_range_subjects) }
  let(:user) { create(:staff) }
  let(:attributes) { {} }
  let(:age_range_subjects_attributes) { {} }

  it_behaves_like "an age range subjects form" do
    let(:assessment) { assessment_section.assessment }
    let(:attributes) { { passed: true } }
  end
end

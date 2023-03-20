# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::PreliminaryCheckForm, type: :model do
  describe "validations" do
    it do
      is_expected.to validate_inclusion_of(
        :preliminary_check_complete,
      ).in_array([true, false])
    end
  end

  describe "#save" do
    let(:assessment) { create(:assessment) }
    subject do
      described_class.new(assessment:, preliminary_check_complete: true)
    end

    it "updates preliminary_check field on the assessment" do
      expect { subject.save }.to change {
        assessment.reload.preliminary_check_complete
      }.from(nil).to(true)
    end
  end
end

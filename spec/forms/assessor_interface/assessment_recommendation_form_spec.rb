# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentRecommendationForm, type: :model do
  let(:assessment) { create(:assessment) }

  subject(:form) { described_class.new(assessment:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:recommendation) }

    context "with an award-able assessment" do
      before { allow(assessment).to receive(:can_award?).and_return(true) }

      it do
        is_expected.to validate_inclusion_of(:recommendation).in_array(
          %w[award],
        )
      end
    end

    context "with a decline-able assessment" do
      before { allow(assessment).to receive(:can_decline?).and_return(true) }

      it do
        is_expected.to validate_inclusion_of(:recommendation).in_array(
          %w[decline],
        )
      end
    end

    context "with can_request_further_information-able assessment" do
      before do
        allow(assessment).to receive(
          :can_request_further_information?,
        ).and_return(true)
      end

      it do
        is_expected.to validate_inclusion_of(:recommendation).in_array(
          %w[request_further_information],
        )
      end
    end
  end
end

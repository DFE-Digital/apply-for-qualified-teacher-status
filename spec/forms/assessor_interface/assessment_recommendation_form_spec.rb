# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentRecommendationForm, type: :model do
  subject(:form) { described_class.new(assessment:) }

  let(:application_form) { create(:application_form) }
  let(:assessment) { create(:assessment, application_form:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:recommendation) }
    it { is_expected.not_to validate_presence_of(:confirmation) }

    context "with an award-able assessment" do
      before { allow(assessment).to receive(:can_award?).and_return(true) }

      it do
        expect(subject).to validate_inclusion_of(:recommendation).in_array(
          %w[award],
        )
      end
    end

    context "with a decline-able assessment" do
      before { allow(assessment).to receive(:can_decline?).and_return(true) }

      it do
        expect(subject).to validate_inclusion_of(:recommendation).in_array(
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
        expect(subject).to validate_inclusion_of(:recommendation).in_array(
          %w[request_further_information],
        )
      end
    end

    context "with an application under old criteria" do
      let(:application_form) { create(:application_form, :old_regulations) }

      before { allow(assessment).to receive(:can_verify?).and_return(true) }

      it { is_expected.to validate_presence_of(:confirmation) }
    end
  end
end

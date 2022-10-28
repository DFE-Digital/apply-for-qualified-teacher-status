# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::AssessmentRecommendationForm, type: :model do
  let(:application_form) { create(:application_form, :submitted) }
  let(:assessment) { create(:assessment, application_form:) }
  let(:user) { create(:staff, :confirmed) }
  let(:attributes) { {} }

  subject(:form) { described_class.new(assessment:, user:, **attributes) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:assessment) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:recommendation) }
    it { is_expected.to_not validate_presence_of(:declaration) }

    context "with an awarded recommendation" do
      let(:attributes) { { recommendation: "award" } }

      it { is_expected.to validate_presence_of(:declaration) }
    end

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

  describe "#save" do
    subject(:save) { form.save }

    describe "with invalid attributes" do
      it { is_expected.to be false }
    end

    describe "with valid attributes" do
      let(:attributes) { { recommendation: "award", declaration: "true" } }

      before { allow(assessment).to receive(:can_award?).and_return(true) }

      it { is_expected.to be true }

      it "sets the recommendation" do
        expect { save }.to change(assessment, :recommendation).to("award")
      end
    end
  end
end

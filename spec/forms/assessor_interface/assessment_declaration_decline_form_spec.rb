# frozen_string_literal: true

require "rails_helper"
RSpec.describe AssessorInterface::AssessmentDeclarationDeclineForm,
               type: :model do
  subject(:form) do
    described_class.new(
      assessment:,
      declaration: true,
      recommendation_assessor_note: "Note",
    )
  end

  let(:assessment) { create(:assessment, :decline) }

  describe "validations" do
    context "when recommendation is declined with no failure reasons" do
      it { is_expected.to validate_presence_of(:recommendation_assessor_note) }
    end

    context "when recommendation is started" do
      before { assessment.update!(started_at: Time.zone.now) }

      it { is_expected.to validate_presence_of(:declaration) }
    end

    context "when recommendation is declined with failure reasons" do
      before do
        create(:assessment_section, :declines_with_already_qts, assessment:)
      end

      it do
        is_expected.not_to validate_presence_of(:recommendation_assessor_note)
      end
    end
  end

  describe "#save" do
    context "when valid" do
      subject(:save) { form.save }

      it { is_expected.to be true }

      it "sets the recommendation note" do
        expect { save }.to change(assessment, :recommendation_assessor_note).to(
          "Note",
        )
      end
    end
  end
end

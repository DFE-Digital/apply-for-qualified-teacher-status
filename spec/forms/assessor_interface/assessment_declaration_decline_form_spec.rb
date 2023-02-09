# frozen_string_literal: true

require "rails_helper"
RSpec.describe AssessorInterface::AssessmentDeclarationDeclineForm,
               type: :model do
  let(:session) { {} }
  subject(:form) do
    described_class.new(
      session:,
      assessment:,
      declaration: true,
      recommendation_assessor_note: "Note",
    )
  end

  describe "validations" do
    context "when recommendation is declined with no failure reasons" do
      let(:assessment) { create(:assessment, :decline) }

      it { is_expected.to validate_presence_of(:recommendation_assessor_note) }
    end

    context "when recommendation is started" do
      let(:assessment) { create(:assessment, :started) }
      it { is_expected.to validate_presence_of(:declaration) }
    end

    context "when recommendation is declined with failure reasons" do
      before do
        create(:assessment_section, :declines_with_already_qts, assessment:)
      end
      let(:assessment) { create(:assessment, :decline) }

      it do
        is_expected.not_to validate_presence_of(:recommendation_assessor_note)
      end
    end
  end

  describe "#save" do
    let(:assessment) { create(:assessment, :decline) }
    context "when valid" do
      subject(:save) { form.save }

      it { is_expected.to be true }
      it "sets the session" do
        expect { save }.to change { session[:recommendation_assessor_note] }.to(
          "Note",
        )
      end
    end
  end
end

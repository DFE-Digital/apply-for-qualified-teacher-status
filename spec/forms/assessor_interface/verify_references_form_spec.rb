# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::VerifyReferencesForm, type: :model do
  let(:assessment) { create(:assessment) }
  let(:references_verified) { nil }

  subject(:form) { described_class.new(assessment:, references_verified:) }

  describe "save" do
    context "when verify_references is nil" do
      it "fails validation" do
        expect(form.save).to be false

        expect(form.errors).to have_key(:references_verified)
      end
    end

    context "when verify_references is passed" do
      let(:references_verified) { true }

      it "updates ApplicationForm#verify_references_status" do
        expect { form.save }.to change(assessment, :references_verified).from(
          nil,
        ).to(true)
      end
    end
  end
end

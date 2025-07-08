# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::PrioritisationWorkHistoryCheckViewObject do
  subject(:view_object) do
    described_class.new(prioritisation_work_history_check:)
  end

  let(:assessment) { create(:assessment) }
  let(:prioritisation_work_history_check) do
    create(:prioritisation_work_history_check, assessment:)
  end

  describe "#disable_form?" do
    subject(:disable_form?) { view_object.disable_form? }

    it { is_expected.to be false }

    context "when the assessment has prioritisation reference requests" do
      before { create :prioritisation_reference_request, assessment: }

      it { is_expected.to be true }
    end
  end
end

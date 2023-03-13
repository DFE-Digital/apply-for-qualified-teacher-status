# frozen_string_literal

require "rails_helper"

RSpec.describe UpdateAssessmentInductionRequired do
  let(:application_form) { create(:application_form) }
  let(:assessment) { create(:assessment, application_form:) }

  subject(:call) { described_class.call(assessment:) }

  shared_examples "induction required" do
    it "sets induction required to true" do
      expect { call }.to change(assessment, :induction_required).to(true)
    end
  end

  shared_examples "induction not required" do
    it "sets induction required to false" do
      expect { call }.to change(assessment, :induction_required).to(false)
    end
  end

  context "with no work history" do
    include_examples "induction required"
  end

  context "with 24 months of work history" do
    before do
      create(
        :work_history,
        application_form:,
        start_date: Date.new(2020, 1, 1),
        end_date: Date.new(2021, 12, 1),
        hours_per_week: 30,
      )
    end

    include_examples "induction required"

    context "when reduced evidence is accepted" do
      before { application_form.update!(reduced_evidence_accepted: true) }

      include_examples "induction not required"
    end
  end

  context "with 24 months of approved work history" do
    before do
      work_history =
        create(
          :work_history,
          application_form:,
          start_date: Date.new(2020, 1, 1),
          end_date: Date.new(2021, 12, 1),
          hours_per_week: 30,
        )
      create(:reference_request, :passed, assessment:, work_history:)
    end

    include_examples "induction not required"
  end
end

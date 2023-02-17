# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssessorInterface::VerifyReferencesViewObject do
  let(:assessment) { create(:assessment) }
  subject(:view_object) { described_class.new(assessment:) }

  describe "#name_and_duration" do
    let(:work_history) do
      create(
        :work_history,
        application_form: assessment.application_form,
        school_name: "School of Rock",
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2022, 12, 22),
        hours_per_week: 30,
      )
    end

    subject(:name_and_duration) { view_object.name_and_duration(work_history) }

    it { is_expected.to eq("School of Rock (12 months)") }

    context "when work history is most recent" do
      subject(:name_and_duration) do
        view_object.name_and_duration(work_history, most_recent: true)
      end

      it do
        is_expected.to eq(
          %(School of Rock (12 months) <span class="govuk-!-font-weight-bold">MOST RECENT</span>),
        )
      end
    end
  end
end

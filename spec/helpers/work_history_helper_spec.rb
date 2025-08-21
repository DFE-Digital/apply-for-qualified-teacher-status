# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkHistoryHelper do
  describe "#work_history_name" do
    subject(:name) { work_history_name(work_history) }

    let(:work_history) { build(:work_history) }

    it { is_expected.to eq("Your current or most recent role as a teacher") }

    context "with a school name" do
      before { work_history.school_name = "Name" }

      it { is_expected.to eq("Name") }
    end

    context "with a city" do
      before { work_history.city = "City" }

      it { is_expected.to eq("City") }
    end

    context "with a country" do
      before { work_history.country_code = "FR" }

      it { is_expected.to eq("France") }
    end

    context "with a job" do
      before { work_history.job = "Job" }

      it { is_expected.to eq("Job") }
    end
  end

  describe "#work_history_name_and_duration" do
    subject(:name_and_duration) { work_history_name_and_duration(work_history) }

    let(:application_form) { create(:application_form) }

    let(:work_history) do
      create(
        :work_history,
        application_form:,
        school_name: "School of Rock",
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2022, 12, 22),
        hours_per_week: 30,
      )
    end

    context "when it is not the most recent" do
      before { create(:work_history, application_form:) }

      it { is_expected.to eq("School of Rock — 12 months") }
    end

    context "when it is the most recent" do
      it do
        expect(subject).to eq(
          %(School of Rock — 12 months <span class="govuk-!-font-weight-bold">(MOST RECENT)</span>),
        )
      end
    end
  end

  describe "#work_history_count_in_months" do
    let(:work_history) { build(:work_history) }
    let(:duration) { instance_double(WorkHistoryDuration, count_months: 6) }

    before do
      allow(WorkHistoryDuration).to receive(:for_record).with(
        work_history,
      ).and_return(duration)
    end

    it "returns the count of months with ' months' appended" do
      expect(helper.work_history_count_in_months(work_history)).to eq(
        "6 months",
      )
    end
  end
end

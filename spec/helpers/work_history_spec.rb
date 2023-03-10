require "rails_helper"

RSpec.describe WorkHistoryHelper do
  describe "#work_history_title" do
    subject(:title) { work_history_title(work_history) }

    let(:work_history) { build(:work_history) }

    it { is_expected.to eq("Your current or most recent role") }

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
    let(:work_history) do
      create(
        :work_history,
        school_name: "School of Rock",
        start_date: Date.new(2022, 1, 1),
        end_date: Date.new(2022, 12, 22),
        hours_per_week: 30,
      )
    end

    subject(:name_and_duration) { work_history_name_and_duration(work_history) }

    it { is_expected.to eq("School of Rock (12 months)") }

    context "when work history is most recent" do
      subject(:name_and_duration) do
        work_history_name_and_duration(work_history, most_recent: true)
      end

      it do
        is_expected.to eq(
          %(School of Rock (12 months) <span class="govuk-!-font-weight-bold">MOST RECENT</span>),
        )
      end
    end
  end
end

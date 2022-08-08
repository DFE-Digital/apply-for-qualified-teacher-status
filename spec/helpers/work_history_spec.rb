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
      before { work_history.country = "Country" }

      it { is_expected.to eq("Country") }
    end

    context "with a job" do
      before { work_history.job = "Job" }

      it { is_expected.to eq("Job") }
    end
  end
end

require "rails_helper"

RSpec.describe PerformanceStats do
  let(:since) { 1.week.ago.beginning_of_day }
  let(:until_days) { 6 }

  subject { PerformanceStats.new(since, until_days) }

  describe "without params" do
    it "asks for a since parameter" do
      expect { PerformanceStats.new(nil, nil) }.to raise_error(
        ArgumentError,
        "since is not a TimeWithZone"
      )
    end

    it "asks for an until_days parameter" do
      expect { PerformanceStats.new(since, nil) }.to raise_error(
        ArgumentError,
        "until_days is not an Integer"
      )
    end
  end

  describe "#live_service_usage" do
    it "calculates live service usage" do
      count, data = subject.live_service_usage
      expect(count).to eq 0
      expect(data.size).to eq 8
    end
  end

  describe "#submission_results" do
    it "calculates submission results" do
      count, data = subject.submission_results
      expect(count).to eq 0
      expect(data.size).to eq 8
    end
  end

  describe "#country_usage" do
    it "calculates country usage" do
      count, data = subject.country_usage
      expect(count).to eq 0
      expect(data.size).to eq 1
    end
  end
end

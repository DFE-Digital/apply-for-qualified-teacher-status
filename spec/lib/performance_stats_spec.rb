require "rails_helper"

RSpec.describe PerformanceStats do
  let(:time_period) { 1.week.ago.beginning_of_day..Time.zone.now }
  let(:until_days) { 6 }

  subject { PerformanceStats.new(time_period, until_days) }

  describe "without params" do
    it "asks for a time_period parameter" do
      expect { PerformanceStats.new(nil, nil) }.to raise_error(
        ArgumentError,
        "time_period is not a Range"
      )
    end

    it "asks for an until_days parameter" do
      expect { PerformanceStats.new(time_period, nil) }.to raise_error(
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

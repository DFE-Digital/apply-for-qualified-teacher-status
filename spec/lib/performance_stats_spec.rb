require "rails_helper"

RSpec.describe PerformanceStats do
  let(:time_period) { 1.week.ago.beginning_of_day..Time.zone.now }

  subject { PerformanceStats.new(time_period) }

  describe "without params" do
    it "asks for a time_period parameter" do
      expect { PerformanceStats.new(nil) }.to raise_error(
        ArgumentError,
        "time_period is not a Range"
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

  describe "#duration_usage" do
    it "calculates duration results" do
      data = subject.duration_usage
      expect(data.size).to eq 8
    end
  end
end

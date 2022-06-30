require "rails_helper"

RSpec.describe PerformanceStats do
  let(:from) { 1.week.ago.beginning_of_day }

  subject { PerformanceStats.new(from:) }

  describe "#live_service_usage" do
    it "calculates live service usage" do
      count, data = subject.live_service_usage
      expect(count).to eq 0
      expect(data.size).to eq 8
    end
  end

  describe "#time_to_complete" do
    it "calculates time to complete" do
      data = subject.time_to_complete
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

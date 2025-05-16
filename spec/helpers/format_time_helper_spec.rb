# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormatTimeHelper do
  describe "#format_human_readable_uk_time" do
    subject(:formatted_time) { helper.format_human_readable_uk_time(time) }

    context "when time is nil" do
      let(:time) { nil }

      it { is_expected.to eq("") }
    end

    context "during British Summer Time" do
      let(:time) { Time.utc(2025, 5, 15, 8, 37, 39) }

      it "formats time with BST adjustment" do
        travel_to(Time.zone.local(2025, 6, 1, 12, 0, 0)) do
          expect(formatted_time).to eq("15 May 2025 at 9:37 am")
        end
      end
    end

    context "during Greenwich Mean Time" do
      let(:time) { Time.utc(2025, 1, 15, 14, 30, 0) }

      it "formats time with GMT" do
        travel_to(Time.zone.local(2025, 12, 1, 12, 0, 0)) do
          expect(formatted_time).to eq("15 January 2025 at 2:30 pm")
        end
      end
    end
  end
end

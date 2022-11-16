# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subject do
  describe "#all" do
    subject(:all) { described_class.all }

    it { is_expected.to_not be_empty }
  end

  describe "#find" do
    subject(:find) { described_class.find(%w[ancient_hebrew economics]) }

    it "contains the right elements" do
      expect(find.count).to eq(2)
      expect(find.first.id).to eq("ancient_hebrew")
      expect(find.second.id).to eq("economics")
    end
  end
end

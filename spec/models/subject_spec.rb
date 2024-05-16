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
      expect(find.first.value).to eq("ancient_hebrew")
      expect(find.second.value).to eq("economics")
    end
  end

  describe "#ebacc?" do
    subject(:ebacc?) { described_class.find([value]).first.ebacc? }

    context "with an EBacc subject" do
      let(:value) { "ancient_hebrew" }
      it { is_expected.to be true }
    end

    context "with a non-EBacc subject" do
      let(:value) { "applied_computing" }
      it { is_expected.to be false }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailDomain do
  describe ".public?" do
    subject(:public?) { described_class.public?(domain) }

    context "with a nil domain?" do
      let(:domain) { nil }

      it { is_expected.to be false }
    end

    context "with a blank country code" do
      let(:domain) { "" }

      it { is_expected.to be false }
    end

    context "with a public domain" do
      let(:domain) { "gmail.com" }

      it { is_expected.to be true }
    end

    context "with a private domain" do
      let(:domain) { "private.com" }

      it { is_expected.to be false }
    end
  end
end

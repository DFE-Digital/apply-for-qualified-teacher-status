# frozen_string_literal: true

require "rails_helper"

RSpec.describe Devise::Otp do
  describe "#valid?" do
    subject(:valid?) { described_class.valid?(secret_key, submitted_otp) }

    let(:secret_key) { ROTP::Base32.random }

    context "if OTPs match" do
      let(:submitted_otp) { ROTP::HOTP.new(secret_key).at(0) }
      it { is_expected.to be true }
    end

    context "if OTPs don't match" do
      let(:submitted_otp) { "bad_guess" }
      it { is_expected.to be false }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Teachers::OtpForm do
  subject(:form) { described_class.new(uuid: user.uuid) }

  describe "#otp_expired?" do
    subject(:otp_expired?) { form.otp_expired? }

    let(:user) { create(:teacher, otp_created_at:) }

    before { freeze_time }
    after { travel_back }

    context "when the OTP is 16 minutes old" do
      let(:otp_created_at) { 16.minutes.ago }

      it { is_expected.to be true }
    end

    context "when the OTP is 14 minutes old" do
      let(:otp_created_at) { 14.minutes.ago }

      it { is_expected.to be false }
    end

    context "when there is no OTP timestamp" do
      let(:otp_created_at) { nil }

      it { is_expected.to be true }
    end
  end

  describe "#secret_key?" do
    subject(:secret_key?) { form.secret_key? }

    context "when user secret_key is present" do
      let(:user) { create(:teacher, secret_key: "test_key") }

      it { is_expected.to be true }
    end

    context "when user secret_key is blank" do
      let(:user) { create(:teacher, secret_key: nil) }

      it { is_expected.to be false }
    end
  end
end

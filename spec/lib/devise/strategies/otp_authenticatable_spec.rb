# frozen_string_literal: true

require "rails_helper"

RSpec.describe Devise::Strategies::OtpAuthenticatable do
  let(:env) do
    env = Rack::MockRequest.env_for("/strategy-test", params)
    env["devise.allow_params_authentication"] = true
    env
  end

  subject(:strategy) { described_class.new(env, :teacher) }

  describe "#valid?" do
    subject(:valid?) { strategy.valid? }

    context "with valid params" do
      let(:params) do
        { params: { teacher: { email: "test@example.com", otp: "123456" } } }
      end

      it { is_expected.to be true }
    end

    context "when the otp param is missing" do
      let(:params) { { params: { teacher: { email: "test@example.com" } } } }

      it { is_expected.to be false }
    end

    context "when the email param is missing" do
      let(:params) { { params: { teacher: { otp: "123456" } } } }

      it { is_expected.to be false }
    end
  end
end

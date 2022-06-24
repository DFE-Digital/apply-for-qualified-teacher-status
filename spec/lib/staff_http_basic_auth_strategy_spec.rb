require "rails_helper"

RSpec.describe StaffHttpBasicAuthStrategy do
  subject(:staff_http_basic_auth_strategy) { described_class.new(env) }

  let(:env) { {} }

  describe "#valid?" do
    subject(:valid?) { staff_http_basic_auth_strategy.valid? }

    context "with staff users" do
      before { create(:staff) }

      it { is_expected.to eq(false) }
    end

    context "when feature is active" do
      before { create(:feature, :active, name: "staff_http_basic_auth") }

      it { is_expected.to eq(true) }
    end

    context "when there are no staff users" do
      it { is_expected.to eq(true) }
    end
  end

  describe "#store?" do
    subject(:store?) { staff_http_basic_auth_strategy.store? }

    it { is_expected.to eq(false) }
  end

  describe "#authenticate!" do
    before { staff_http_basic_auth_strategy.authenticate! }

    it "should halt the strategy" do
      expect(staff_http_basic_auth_strategy.halted?).to eq(true)
    end

    it "should not be successful" do
      expect(staff_http_basic_auth_strategy.successful?).to eq(false)
      expect(staff_http_basic_auth_strategy.custom_response).to eq(
        [
          401,
          {
            "Content-Length" => "0",
            "Content-Type" => "text/plain",
            "WWW-Authenticate" => "Basic realm=\"Application\""
          },
          []
        ]
      )
    end

    context "with valid credentials" do
      let(:env) do
        { "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("test:test")}" }
      end

      it "should be successful" do
        expect(staff_http_basic_auth_strategy.successful?).to eq(true)
      end
    end
  end
end

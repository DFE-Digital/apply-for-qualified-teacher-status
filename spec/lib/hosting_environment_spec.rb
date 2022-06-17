require "rails_helper"

RSpec.describe HostingEnvironment do
  describe "#name" do
    subject(:name) { described_class.name }

    context "when the environment variable is set" do
      around do |example|
        ClimateControl.modify(HOSTING_ENVIRONMENT: "production") { example.run }
      end

      it { is_expected.to eq("production") }
    end

    context "when the environment variable isn't set" do
      it { is_expected.to eq("development") }
    end
  end
end

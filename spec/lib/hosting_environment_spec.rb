require "rails_helper"

RSpec.describe HostingEnvironment do
  let(:hosting_environment) { nil }

  around do |example|
    ClimateControl.modify(HOSTING_ENVIRONMENT: hosting_environment) do
      example.run
    end
  end

  describe "#name" do
    subject(:name) { described_class.name }

    context "when the environment variable is set" do
      let(:hosting_environment) { "production" }

      it { is_expected.to eq("production") }
    end

    context "when the environment variable isn't set" do
      it { is_expected.to eq("dev") }
    end
  end

  describe "#host" do
    subject(:host) { described_class.host }

    context "when the environment is production" do
      let(:hosting_environment) { "production" }

      it { is_expected.to eq("apply-for-qts-in-england.education.gov.uk") }
    end

    context "when the environment is preprod" do
      let(:hosting_environment) { "preprod" }

      it do
        is_expected.to eq("preprod.apply-for-qts-in-england.education.gov.uk")
      end
    end

    context "when the environment is test" do
      let(:hosting_environment) { "test" }

      it { is_expected.to eq("test.apply-for-qts-in-england.education.gov.uk") }
    end

    context "when the environment is dev" do
      let(:hosting_environment) { "dev" }

      it { is_expected.to eq("dev.apply-for-qts-in-england.education.gov.uk") }
    end
  end
end

require "spec_helper"

RSpec.describe HostingEnvironment do
  let(:hosting_environment) { nil }
  let(:application_name) { "apply-for-qts-in-england-review-pr-292" }
  let(:vcap_application) { "{\"application_name\":\"#{application_name}\"}" }

  around do |example|
    ClimateControl.modify(
      HOSTING_ENVIRONMENT: hosting_environment,
      VCAP_APPLICATION: vcap_application
    ) { example.run }
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

    context "when the environment is review" do
      let(:hosting_environment) { "review" }

      it do
        is_expected.to eq(
          "apply-for-qts-in-england-review-pr-292.london.cloudapps.digital"
        )
      end

      context "running on a worker" do
        let(:application_name) do
          "apply-for-qts-in-england-review-pr-292-worker"
        end

        it do
          is_expected.to eq(
            "apply-for-qts-in-england-review-pr-292.london.cloudapps.digital"
          )
        end
      end
    end
  end
end

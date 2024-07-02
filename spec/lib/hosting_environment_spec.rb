# frozen_string_literal: true

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
      it { is_expected.to eq("development") }
    end
  end

  describe "#host" do
    subject(:host) { described_class.host }

    context "when the environment is production" do
      let(:hosting_environment) { "production" }

      it { is_expected.to eq("apply-for-qts-in-england.education.gov.uk") }
    end

    context "when the environment is preprod" do
      let(:hosting_environment) { "preproduction" }

      it do
        expect(subject).to eq(
          "preprod.apply-for-qts-in-england.education.gov.uk",
        )
      end
    end

    context "when the environment is test" do
      let(:hosting_environment) { "test" }

      it { is_expected.to eq("test.apply-for-qts-in-england.education.gov.uk") }
    end

    context "when the environment is development" do
      let(:hosting_environment) { "development" }

      it { is_expected.to eq("dev.apply-for-qts-in-england.education.gov.uk") }
    end

    context "when the environment is review" do
      let(:hosting_environment) { "review-292" }

      it do
        expect(subject).to eq(
          "apply-for-qts-review-292-web.test.teacherservices.cloud",
        )
      end
    end
  end
end

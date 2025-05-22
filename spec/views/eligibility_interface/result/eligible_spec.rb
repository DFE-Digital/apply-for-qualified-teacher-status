# frozen_string_literal: true

require "rails_helper"

RSpec.describe "eligibility_interface/result/eligible.html.erb", type: :view do
  subject { render }

  let(:region) { create :region }
  let(:eligibility_check) { create :eligibility_check }

  before do
    assign(:region, region)
    assign(:eligibility_check, eligibility_check)
  end

  it do
    expect(subject).to match(
      /You’re eligible to apply for qualified teacher status/,
    )
  end

  it do
    expect(subject).not_to match(
      /You need a GOV.UK One Login to use this service./,
    )
  end

  it { expect(subject).not_to match(/using a GOV.UK One Login/) }

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it do
      expect(subject).to match(
        /You need a GOV.UK One Login to use this service./,
      )
    end

    it { expect(subject).to match(/using a GOV.UK One Login/) }
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "eligibility_interface/start/show.html.erb", type: :view do
  subject { render }

  around do |example|
    FeatureFlags::FeatureFlag.activate(:teacher_applications)
    example.run
    FeatureFlags::FeatureFlag.deactivate(:teacher_applications)
  end

  it do
    expect(subject).to match(
      /Check you’re eligible to apply for qualified teacher status/,
    )
  end

  it do
    expect(subject).to match(
      /If you’ve already started your application using this service, you can/,
    )
  end

  it do
    expect(subject).not_to match(
      /You need a GOV.UK One Login to use this service./,
    )
  end

  it { expect(subject).not_to match(/using a GOV.UK One Login./) }

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

    it { expect(subject).to match(/using a GOV.UK One Login./) }

    it do
      expect(subject).not_to match(
        /If you’ve already started your application using this service, you can/,
      )
    end
  end
end

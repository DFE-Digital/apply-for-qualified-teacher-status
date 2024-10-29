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

  context "with GOV.UK One Login enabled" do
    around do |example|
      FeatureFlags::FeatureFlag.activate(:gov_one_applicant_login)
      example.run
      FeatureFlags::FeatureFlag.deactivate(:gov_one_applicant_login)
    end

    it do
      expect(subject).to match(
        /If you’ve already started your application using this service, you can/,
      )
    end
  end
end

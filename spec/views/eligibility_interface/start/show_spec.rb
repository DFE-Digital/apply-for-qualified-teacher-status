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

  context "when no country is subject-limited" do
    before { create(:country) }

    it "does not display the subject and age content" do
      expect(subject).not_to include(
        "Depending on the country that you trained to teach in",
        "11 and 16 years old",
        "a teaching specialism in one of the following subjects",
      )
    end
  end

  context "when a country is subject-limited" do
    before { create(:country, :subject_limited) }

    it "displays the subject and age content" do
      expect(subject).to include(
        "Depending on the country that you trained to teach in",
        "11 and 16 years old",
        "a teaching specialism in one of the following subjects",
      )
    end
  end

  context "when a subject-limited country is ineligible" do
    before { create(:country, :subject_limited, :ineligible) }

    it "does not display the subject and age content" do
      expect(subject).not_to include(
        "Depending on the country that you trained to teach in",
        "11 and 16 years old",
        "a teaching specialism in one of the following subjects",
      )
    end
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

require "rails_helper"

RSpec.describe "Eligible region content", type: :view do
  let(:region) { nil }

  before { render "shared/eligible_region_content", region: }

  subject { rendered }

  it { is_expected.to match(/You’re eligible/) }
  it { is_expected.to_not match(/What we’ll ask for/) }

  context "with a fully online region" do
    let(:region) do
      create(:region, status_check: :online, sanction_check: :online)
    end

    it { is_expected.to match(/has an online register of teachers/) }
  end

  context "with a fully written region" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :written,
        sanction_check: :written,
        teaching_authority_address: "address",
      )
    end

    it { is_expected.to match(/recognises you as a teacher must confirm/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
  end

  context "with an online status check and written sanction check" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :online,
        sanction_check: :written,
        teaching_authority_address: "address",
      )
    end

    it { is_expected.to match(/has an online register of teachers/) }
    it { is_expected.to match(/must also confirm in writing/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
  end

  context "with a written status check and no sanction check" do
    let(:region) do
      create(
        :region,
        country:
          create(:country, teaching_authority_certificate: "certificate"),
        status_check: :written,
        sanction_check: :none,
        teaching_authority_address: "address",
      )
    end

    it { is_expected.to match(/recognises you as a teacher must confirm/) }
    it { is_expected.to match(/You’ll need to provide a/) }
    it { is_expected.to match(/certificate/) }
    it { is_expected.to match(/address/) }
    it { is_expected.to match(/show evidence of your work history/) }
  end

  context "with no status check and no sanction check" do
    let(:region) { create(:region, status_check: :none, sanction_check: :none) }

    it { is_expected.to match(/show evidence of your work history/) }
  end
end

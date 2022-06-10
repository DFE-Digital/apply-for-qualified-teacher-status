require "rails_helper"

RSpec.describe "eligibility_interface/pages/eligible", type: :view do
  before do
    assign(:region, region)
    render
  end

  subject { rendered }

  context "without a region" do
    let(:region) { nil }

    it { is_expected.to match(/You’re eligible/) }
    it { is_expected.to_not match(/What we’ll ask for/) }
  end

  context "with a legacy region" do
    let(:region) { create(:region, :legacy) }

    it { is_expected.to match(/You’re eligible/) }
    it { is_expected.to_not match(/What we’ll ask for/) }
  end

  context "with a non-legacy region" do
    let(:region) { create(:region) }

    it { is_expected.to match(/You’re eligible/) }
    it { is_expected.to match(/What we’ll ask for/) }
  end
end

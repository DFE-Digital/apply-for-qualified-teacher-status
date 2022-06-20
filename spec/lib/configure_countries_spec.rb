require "rails_helper"

RSpec.describe ConfigureCountries do
  describe "#private_beta!" do
    let(:ireland) do
      Region.joins(:country).find_by!(country: { code: "IE" }, name: "")
    end
    let(:poland) do
      Region.joins(:country).find_by!(country: { code: "PL" }, name: "")
    end
    let(:hawaii) do
      Region.joins(:country).find_by!(country: { code: "US" }, name: "Hawaii")
    end
    let(:spain) do
      Region.joins(:country).find_by!(country: { code: "ES" }, name: "")
    end
    let(:british_columbia) do
      Region.joins(:country).find_by!(
        country: {
          code: "CA"
        },
        name: "British Columbia"
      )
    end
    let(:cyprus) do
      Region.joins(:country).find_by!(country: { code: "CY" }, name: "")
    end
    let(:france) do
      Region.joins(:country).find_by!(country: { code: "FR" }, name: "")
    end

    before { described_class.private_beta! }

    it "sets legacy attribute on approriate regions" do
      expect(ireland.reload.legacy).to eq(false)
      expect(poland.reload.legacy).to eq(false)
      expect(hawaii.reload.legacy).to eq(false)
      expect(spain.reload.legacy).to eq(false)
      expect(british_columbia.reload.legacy).to eq(false)
      expect(cyprus.reload.legacy).to eq(false)
      expect(france.reload.legacy).to eq(true)
    end
  end
end

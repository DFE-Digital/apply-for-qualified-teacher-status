require "rails_helper"

RSpec.describe ConfigureCountries do
  describe "#private_beta!" do
    let!(:ireland) do
      create(:region, :national, country: create(:country, code: "IE"))
    end
    let!(:poland) do
      create(:region, :national, country: create(:country, code: "PL"))
    end
    let!(:hawaii) do
      create(:region, name: "Hawaii", country: create(:country, code: "US"))
    end
    let!(:spain) do
      create(:region, :national, country: create(:country, code: "ES"))
    end
    let!(:british_columbia) do
      create(
        :region,
        name: "British Columbia",
        country: create(:country, code: "CA")
      )
    end
    let!(:cyprus) do
      create(:region, :national, country: create(:country, code: "CY"))
    end
    let!(:other) { create(:region, :national) }

    before { described_class.private_beta! }

    it "sets legacy attribute on approriate regions" do
      expect(ireland.reload.legacy).to eq(false)
      expect(poland.reload.legacy).to eq(false)
      expect(hawaii.reload.legacy).to eq(false)
      expect(spain.reload.legacy).to eq(false)
      expect(british_columbia.reload.legacy).to eq(false)
      expect(cyprus.reload.legacy).to eq(false)
      expect(other.reload.legacy).to eq(true)
    end
  end
end

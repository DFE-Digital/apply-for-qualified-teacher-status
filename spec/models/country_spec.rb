# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:code).in_array(%w[GB-SCT FR]) }
    it { is_expected.to_not validate_inclusion_of(:code).in_array(%w[ABC]) }
  end

  describe "#name" do
    subject(:name) { country.name }

    let(:country) { create(:country, code: "GB-SCT") }

    it { is_expected.to eq("Scotland") }
  end
end

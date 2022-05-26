# == Schema Information
#
# Table name: countries
#
#  id               :bigint           not null, primary key
#  code             :string           not null
#  eligible_content :text             default(""), not null
#  legacy           :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  describe "validations" do
    it { is_expected.to validate_inclusion_of(:code).in_array(%w[GB FR]) }
    it { is_expected.to_not validate_inclusion_of(:code).in_array(%w[ABC]) }
  end
end

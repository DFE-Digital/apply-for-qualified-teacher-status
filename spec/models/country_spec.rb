# == Schema Information
#
# Table name: countries
#
#  id                         :bigint           not null, primary key
#  code                       :string           not null
#  eligibility_enabled        :boolean          default(TRUE), not null
#  eligibility_skip_questions :boolean          default(FALSE), not null
#  other_information          :text             default(""), not null
#  qualifications_information :text             default(""), not null
#  sanction_information       :string           default(""), not null
#  status_information         :string           default(""), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  subject(:country) { build(:country) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_inclusion_of(:code).in_array(%w[GB-SCT FR]) }
    it { is_expected.to_not validate_inclusion_of(:code).in_array(%w[ABC]) }
  end
end

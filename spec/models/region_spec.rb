# == Schema Information
#
# Table name: regions
#
#  id         :bigint           not null, primary key
#  name       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :bigint           not null
#
# Indexes
#
#  index_regions_on_country_id           (country_id)
#  index_regions_on_country_id_and_name  (country_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
require "rails_helper"

RSpec.describe Region, type: :model do
  subject(:region) { build(:region) }

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:country_id) }
  end
end

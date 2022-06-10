# == Schema Information
#
# Table name: regions
#
#  id         :bigint           not null, primary key
#  legacy     :boolean          default(TRUE), not null
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
class Region < ApplicationRecord
  belongs_to :country
  has_many :eligibility_checks

  validates :name, uniqueness: { scope: :country_id }

  def full_name
    string = country.name
    string += " — #{name}" if name.present?
    string
  end
end

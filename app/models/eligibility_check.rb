# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  country_code      :string
#  degree            :boolean
#  free_of_sanctions :boolean
#  qualification     :boolean
#  recognised        :boolean
#  teach_children    :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  region_id         :bigint
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
class EligibilityCheck < ApplicationRecord
  belongs_to :region, optional: true

  def ineligible_reasons
    [
      !country ? :country : nil,
      !degree ? :degree : nil,
      !qualification ? :qualification : nil,
      !teach_children ? :teach_children : nil,
      !recognised ? :recognised : nil,
      !free_of_sanctions ? :misconduct : nil
    ].compact
  end

  def eligible?
    ineligible_reasons.empty?
  end

  def country
    @country ||= Country.find_by(code: country_code)
  end

  def country_eligibility_status
    return :legacy if country&.legacy
    return :eligible if country
    :ineligible
  end
end

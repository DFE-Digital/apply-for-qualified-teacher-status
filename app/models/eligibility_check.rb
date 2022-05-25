# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  degree            :boolean
#  country_code      :string
#  free_of_sanctions :boolean
#  qualification     :boolean
#  recognised        :boolean
#  teach_children    :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class EligibilityCheck < ApplicationRecord
  def ineligible_reasons
    [
      !free_of_sanctions ? :misconduct : nil,
      !recognised ? :recognised : nil,
      !teach_children ? :teach_children : nil,
      !qualification ? :qualification : nil,
      !degree ? :degree : nil,
      !(eligible_country_code? || legacy_country_code?) ? :country : nil
    ].compact
  end

  def eligible?
    ineligible_reasons.empty?
  end

  def eligible_country_code?
    ELIGIBLE_COUNTRY_CODES.include?(country_code)
  end

  def legacy_country_code?
    LEGACY_COUNTRY_CODES.include?(country_code)
  end

  ELIGIBLE_COUNTRY_CODES = ["GB"].freeze

  LEGACY_COUNTRY_CODES = ["FR"].freeze
end

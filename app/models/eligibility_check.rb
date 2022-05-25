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
  def ineligible_reason
    return :misconduct unless free_of_sanctions.nil? || free_of_sanctions
    return :recognised unless recognised.nil? || recognised
    return :teach_children unless teach_children.nil? || teach_children
    return :qualification unless qualification.nil? || qualification
    return :degree unless degree.nil? || degree
    if !country_code.nil? && !eligible_country_code? && !legacy_country_code?
      return :country
    end

    nil
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

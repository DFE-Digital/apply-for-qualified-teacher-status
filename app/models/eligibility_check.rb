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
    return :country if !country_code.nil? && country_code == "INELIGIBLE"

    nil
  end
end

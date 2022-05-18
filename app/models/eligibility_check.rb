# == Schema Information
#
# Table name: eligibility_checks
#
#  id                :bigint           not null, primary key
#  free_of_sanctions :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  recognised        :boolean
#  teach_children    :boolean
#
class EligibilityCheck < ApplicationRecord
  def ineligible_reason
    return :misconduct unless free_of_sanctions.nil? || free_of_sanctions
    return :recognised unless recognised.nil? || recognised
    return :teach_children unless teach_children.nil? || teach_children

    nil
  end
end

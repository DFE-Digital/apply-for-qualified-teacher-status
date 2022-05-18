class EligibilityCheck < ApplicationRecord
  def ineligible_reason
    return :misconduct unless free_of_sanctions.nil? || free_of_sanctions
    return :recognised unless recognised.nil? || recognised
    return :teach_children unless teach_children.nil? || teach_children
    return :qualification unless qualification.nil? || qualification

    nil
  end
end

class EligibilityCheck < ApplicationRecord
  def ineligible_reason
    return :misconduct unless free_of_sanctions.nil? || free_of_sanctions
    return :recognised unless recognised.nil? || recognised

    nil
  end
end

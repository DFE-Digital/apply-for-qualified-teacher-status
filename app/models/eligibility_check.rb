class EligibilityCheck < ApplicationRecord
  def ineligible_reason
    return :misconduct unless free_of_sanctions
  end
end

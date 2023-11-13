# frozen_string_literal: true

class EligibilityInterface::FinishController < EligibilityInterface::BaseController
  before_action :ensure_eligibility_check_status
  before_action :complete_eligibility_check
  before_action :load_eligibility_check

  def result
    if eligibility_check.eligible?
      redirect_to %i[eligibility_interface eligible]
    else
      redirect_to %i[eligibility_interface ineligible]
    end
  end

  def eligible
    unless eligibility_check.eligible?
      redirect_to %i[eligibility_interface ineligible]
    end

    @region = eligibility_check.region
    session[:eligibility_check_complete] = true
  end

  def ineligible
    if eligibility_check.eligible?
      redirect_to %i[eligibility_interface eligible]
    end
  end

  private

  def ensure_eligibility_check_status
    if eligibility_check.status != :eligibility
      redirect_to eligibility_interface_start_path
    end
  end

  def complete_eligibility_check
    eligibility_check.complete! if eligibility_check.persisted?
  end

  def load_eligibility_check
    @eligibility_check = eligibility_check
  end
end

# frozen_string_literal: true

class EligibilityInterface::ResultController < EligibilityInterface::BaseController
  include EnforceEligibilityQuestionOrder

  def show
    eligibility_check.complete! if eligibility_check.persisted?

    render eligibility_check.eligible?(includes_email_domains_for_referees: true) ? "eligible" : "ineligible"
  end
end

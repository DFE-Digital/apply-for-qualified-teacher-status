# frozen_string_literal: true

class EligibilityInterface::ResultController < EligibilityInterface::BaseController
  include EnforceEligibilityQuestionOrder

  def show
    eligibility_check.complete! if eligibility_check.persisted?

    render(
      if eligibility_check.eligible?(includes_email_domains_for_referees: true)
        "eligible"
      else
        "ineligible"
      end,
    )
  end
end

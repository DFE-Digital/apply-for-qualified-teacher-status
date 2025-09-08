# frozen_string_literal: true

class EligibilityInterface::ResultController < EligibilityInterface::BaseController
  include EnforceEligibilityQuestionOrder

  def show
    eligibility_check.complete! if eligibility_check.persisted?

    render(
      if eligibility_check.eligible?(includes_email_domains_for_referees:)
        "eligible"
      else
        "ineligible"
      end,
    )
  end

  private

  def includes_email_domains_for_referees
    FeatureFlags::FeatureFlag.active?(:email_domains_for_referees)
  end
end

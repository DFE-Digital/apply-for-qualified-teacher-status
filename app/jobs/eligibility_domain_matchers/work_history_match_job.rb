# frozen_string_literal: true

class EligibilityDomainMatchers::WorkHistoryMatchJob < ApplicationJob
  def perform(work_history)
    eligibility_domain =
      EligibilityDomain.find_by(domain: work_history.contact_email_domain)

    return if eligibility_domain.blank?

    eligibility_domain.with_lock do
      work_history.update!(eligibility_domain:)
      eligibility_domain.update!(
        application_forms_count: eligibility_domain.application_forms.count,
      )
    end
  end
end

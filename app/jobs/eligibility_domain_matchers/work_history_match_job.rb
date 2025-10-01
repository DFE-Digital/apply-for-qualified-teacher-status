# frozen_string_literal: true

class EligibilityDomainMatchers::WorkHistoryMatchJob < ApplicationJob
  def perform(work_history)
    existing_eligibility_domain = work_history.eligibility_domain

    eligibility_domain =
      EligibilityDomain.find_by(domain: work_history.contact_email_domain)

    work_history.update!(eligibility_domain:)

    if eligibility_domain.present?
      eligibility_domain.with_lock do
        eligibility_domain.update!(
          application_forms_count:
            eligibility_domain.application_forms.reload.count,
        )
      end
    end

    if existing_eligibility_domain.present?
      existing_eligibility_domain.with_lock do
        existing_eligibility_domain.update!(
          application_forms_count:
            existing_eligibility_domain.application_forms.reload.count,
        )
      end
    end
  end
end

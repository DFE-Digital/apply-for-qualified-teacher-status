# frozen_string_literal: true

class EligibilityDomains::ApplicationFormsCounterJob < ApplicationJob
  def perform(eligibility_domain)
    eligibility_domain.with_lock do
      eligibility_domain.update!(
        application_forms_count:
          eligibility_domain.application_forms.reload.count,
      )
    end
  end
end

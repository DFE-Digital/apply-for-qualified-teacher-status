# frozen_string_literal: true

class EligibilityDomains::WorkHistoryMatcherJob < ApplicationJob
  def perform(eligibility_domain)
    ActiveRecord::Base.transaction do
      work_histories =
        WorkHistory
          .joins(:application_form)
          .where.not(application_form: { submitted_at: nil })
          .where(contact_email_domain: eligibility_domain.domain)

      work_histories.find_each do |work_history|
        work_history.update!(eligibility_domain:)
      end
    end

    EligibilityDomains::ApplicationFormsCounterJob.perform_later(
      eligibility_domain,
    )
  end
end

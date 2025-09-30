# frozen_string_literal: true

class EligibilityDomainMatchers::EligibilityDomainMatchJob < ApplicationJob
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

      eligibility_domain.update!(
        application_forms_count: eligibility_domain.application_forms.count,
      )
    end
  end
end

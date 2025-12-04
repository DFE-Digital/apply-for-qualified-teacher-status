# frozen_string_literal: true

module TeacherInterface
  class WorkHistoryContactForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :work_history
    attribute :contact_name, :string
    attribute :contact_job, :string
    attribute :contact_email, :string

    validates :contact_name, presence: true, string_length: true
    validates :contact_job, presence: true, string_length: true
    validates :contact_email,
              presence: true,
              string_length: true,
              valid_for_notify: true

    validate :contact_email_has_private_email_domain

    def update_model
      application_form.update!(
        requires_private_email_for_referee: requires_private_email_for_referee?,
      )

      work_history.update!(
        contact_name:,
        contact_job:,
        contact_email:,
        canonical_contact_email: parsed_contact_email.canonical,
        contact_email_domain: parsed_contact_email.host_name,
      )
    end

    delegate :application_form, to: :work_history

    private

    def parsed_contact_email
      EmailAddress.new(contact_email)
    end

    def contact_email_has_private_email_domain
      return unless requires_private_email_for_referee?

      if EmailDomain.public?(parsed_contact_email.host_name)
        errors.add(:contact_email, :invalid_email_domain)
      end
    end

    # TODO: Once all existing draft applications have gone through post release,
    # we no longer need to do this check on any of the above. This would mean that
    # all existing draft application have started_with_private_email_for_referee is true
    def requires_private_email_for_referee?
      FeatureFlags::FeatureFlag.active?(:email_domains_for_referees)
    end
  end
end

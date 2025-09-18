# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestItemWorkHistoryContactForm < BaseForm
    attr_accessor :further_information_request_item
    attribute :contact_name, :string
    attribute :contact_job, :string
    attribute :contact_email, :string

    validates :further_information_request_item, presence: true
    validates :contact_name, :contact_job, presence: true
    validates :contact_email, presence: true, valid_for_notify: true

    validate :contact_email_has_private_email_domain

    def update_model
      further_information_request_item.update(
        contact_name:,
        contact_job:,
        contact_email:,
      )
    end

    delegate :application_form, to: :further_information_request_item

    private

    def parsed_contact_email
      EmailAddress.new(contact_email)
    end

    def contact_email_has_private_email_domain
      return unless application_form.requires_private_email_for_referee?

      if EmailDomain.public?(parsed_contact_email.host_name)
        errors.add(:contact_email, :invalid_email_domain)
      end
    end
  end
end

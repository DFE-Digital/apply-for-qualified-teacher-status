# frozen_string_literal: true

module TeacherInterface
  class WorkHistoryContactForm < BaseForm
    include ActiveRecord::AttributeAssignment

    attr_accessor :work_history
    attribute :contact_name, :string
    attribute :contact_job, :string
    attribute :contact_email, :string

    validates :contact_name, presence: true
    validates :contact_job, presence: true
    validates :contact_email, presence: true, valid_for_notify: true

    def update_model
      email_address = EmailAddress.new(contact_email)

      work_history.update!(
        contact_name:,
        contact_job:,
        contact_email:,
        canonical_contact_email: email_address.canonical,
        contact_email_domain: email_address.host_name,
      )
    end

    delegate :application_form, to: :work_history
  end
end

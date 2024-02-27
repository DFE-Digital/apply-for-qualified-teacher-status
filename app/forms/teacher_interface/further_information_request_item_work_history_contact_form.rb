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

    def update_model
      further_information_request_item.update(
        contact_name:,
        contact_job:,
        contact_email:,
      )
    end
  end
end

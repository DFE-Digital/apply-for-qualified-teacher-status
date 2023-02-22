# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestContactResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :contact_response, :boolean
    attribute :contact_name, :string
    attribute :contact_job, :string
    attribute :contact_comment, :string

    validates :reference_request, presence: true
    validates :contact_response, inclusion: [true, false]
    validates :contact_name,
              presence: true,
              if: -> { contact_response == false }
    validates :contact_job, presence: true, if: -> { contact_response == false }

    def update_model
      reference_request.update!(
        contact_response:,
        contact_name:,
        contact_job:,
        contact_comment:,
      )
    end
  end
end

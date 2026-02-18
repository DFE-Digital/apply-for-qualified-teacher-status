# frozen_string_literal: true

module TeacherInterface
  class PrioritisationReferenceRequestContactResponseForm < BaseForm
    attr_accessor :prioritisation_reference_request
    attribute :contact_response, :boolean
    attribute :contact_comment, :string

    validates :prioritisation_reference_request, presence: true
    validates :contact_response, inclusion: [true, false]
    validates :contact_comment,
              presence: true,
              max_text_length: true,
              if: -> { contact_response == false }

    def update_model
      prioritisation_reference_request.update!(
        contact_response:,
        contact_comment:,
      )
    end
  end
end

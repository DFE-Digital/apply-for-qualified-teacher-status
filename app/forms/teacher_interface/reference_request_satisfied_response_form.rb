# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestSatisfiedResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :satisfied_response, :boolean
    attribute :satisfied_comment, :string

    validates :reference_request, presence: true
    validates :satisfied_response, inclusion: [true, false]
    validates :satisfied_comment,
              presence: true,
              max_text_length: true,
              if: -> { satisfied_response == false }

    def update_model
      reference_request.update!(satisfied_response:, satisfied_comment:)
    end
  end
end

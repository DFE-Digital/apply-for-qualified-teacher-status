# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestLessonsResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :lessons_response, :boolean
    attribute :lessons_comment, :string

    validates :reference_request, presence: true
    validates :lessons_response, inclusion: [true, false]
    validates :lessons_comment,
              presence: true,
              text_length: true,
              if: -> { lessons_response == false }

    def update_model
      reference_request.update!(lessons_response:, lessons_comment:)
    end
  end
end

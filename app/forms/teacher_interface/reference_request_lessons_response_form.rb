# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestLessonsResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :lessons_response, :boolean

    validates :reference_request, presence: true
    validates :lessons_response, inclusion: [true, false]

    def update_model
      reference_request.update!(lessons_response:)
    end
  end
end

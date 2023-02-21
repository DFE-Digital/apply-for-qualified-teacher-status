# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestSatisfiedResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :satisfied_response, :boolean

    validates :reference_request, presence: true
    validates :satisfied_response, inclusion: [true, false]

    def update_model
      reference_request.update!(satisfied_response:)
    end
  end
end

# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestDatesResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :dates_response, :boolean

    validates :reference_request, presence: true
    validates :dates_response, inclusion: [true, false]

    def update_model
      reference_request.update!(dates_response:)
    end
  end
end

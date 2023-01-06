# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestHoursResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :hours_response, :boolean

    validates :reference_request, presence: true
    validates :hours_response, inclusion: [true, false]

    def update_model
      reference_request.update!(hours_response:)
    end
  end
end

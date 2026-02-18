# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestHoursResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :hours_response, :boolean
    attribute :hours_comment, :string

    validates :reference_request, presence: true
    validates :hours_response, inclusion: [true, false]
    validates :hours_comment,
              presence: true,
              max_text_length: true,
              if: -> { hours_response == false }

    def update_model
      reference_request.update!(hours_response:, hours_comment:)
    end
  end
end

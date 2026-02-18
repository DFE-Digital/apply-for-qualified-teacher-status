# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestDatesResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :dates_response, :boolean
    attribute :dates_comment, :string

    validates :reference_request, presence: true
    validates :dates_response, inclusion: [true, false]
    validates :dates_comment,
              presence: true,
              max_text_length: true,
              if: -> { dates_response == false }

    def update_model
      reference_request.update!(dates_response:, dates_comment:)
    end
  end
end

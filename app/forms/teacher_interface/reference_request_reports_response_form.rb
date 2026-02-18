# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestReportsResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :reports_response, :boolean
    attribute :reports_comment, :string

    validates :reference_request, presence: true
    validates :reports_response, inclusion: [true, false]
    validates :reports_comment,
              presence: true,
              max_text_length: true,
              if: -> { reports_response == false }

    def update_model
      reference_request.update!(reports_response:, reports_comment:)
    end
  end
end

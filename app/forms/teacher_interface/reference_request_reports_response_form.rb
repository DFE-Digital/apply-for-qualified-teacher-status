# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestReportsResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :reports_response, :boolean

    validates :reference_request, presence: true
    validates :reports_response, inclusion: [true, false]

    def update_model
      reference_request.update!(reports_response:)
    end
  end
end

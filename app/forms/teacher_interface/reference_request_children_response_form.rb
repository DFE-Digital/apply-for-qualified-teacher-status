# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestChildrenResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :children_response, :boolean

    validates :reference_request, presence: true
    validates :children_response, inclusion: [true, false]

    def update_model
      reference_request.update!(children_response:)
    end
  end
end

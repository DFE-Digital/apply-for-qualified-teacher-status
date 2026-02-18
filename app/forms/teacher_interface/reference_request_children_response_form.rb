# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestChildrenResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :children_response, :boolean
    attribute :children_comment, :string

    validates :reference_request, presence: true
    validates :children_response, inclusion: [true, false]
    validates :children_comment,
              presence: true,
              max_text_length: true,
              if: -> { children_response == false }

    def update_model
      reference_request.update!(children_response:, children_comment:)
    end
  end
end

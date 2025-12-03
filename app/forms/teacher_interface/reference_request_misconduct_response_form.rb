# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestMisconductResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :misconduct_response, :boolean
    attribute :misconduct_comment, :string

    validates :reference_request, presence: true
    validates :misconduct_response, inclusion: [true, false]
    validates :misconduct_comment,
              presence: true,
              text_length: true,
              if: -> { misconduct_response == true }

    def update_model
      reference_request.update!(misconduct_response:, misconduct_comment:)
    end
  end
end

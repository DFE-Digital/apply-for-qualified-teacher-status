# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestMisconductResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :misconduct_response, :boolean

    validates :reference_request, presence: true
    validates :misconduct_response, inclusion: [true, false]

    def update_model
      reference_request.update!(misconduct_response:)
    end
  end
end

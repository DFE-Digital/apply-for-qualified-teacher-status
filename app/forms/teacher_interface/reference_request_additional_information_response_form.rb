# frozen_string_literal: true

module TeacherInterface
  class ReferenceRequestAdditionalInformationResponseForm < BaseForm
    attr_accessor :reference_request
    attribute :additional_information_response, :string

    validates :reference_request, presence: true

    def update_model
      reference_request.update!(additional_information_response:)
    end
  end
end

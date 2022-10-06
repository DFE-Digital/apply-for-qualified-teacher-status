# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestItemTextForm < BaseForm
    attr_accessor :further_information_request_item
    attribute :response, :string

    validates :further_information_request_item, presence: true
    validates :response, presence: true

    def update_model
      further_information_request_item.update!(response:)
    end
  end
end

# frozen_string_literal: true

class TeacherInterface::FurtherInformationRequestItemTextForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :further_information_request_item
  attribute :response, :string

  validates :further_information_request_item, presence: true
  validates :response, presence: true

  def save
    return false unless valid?
    update_model
    true
  end

  def update_model
    further_information_request_item.update!(response:)
  end
end

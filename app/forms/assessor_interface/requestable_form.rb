# frozen_string_literal: true

class AssessorInterface::RequestableForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable
  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  def save
    return false if invalid?

    requestable.reviewed!(passed)
    true
  end

  delegate :assessment, to: :requestable
  delegate :application_form, to: :assessment
end

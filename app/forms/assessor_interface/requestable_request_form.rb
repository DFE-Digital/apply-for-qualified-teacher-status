# frozen_string_literal: true

class AssessorInterface::RequestableRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user, :application_form, :assessment
  validates :requestable, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  delegate :application_form, :assessment, to: :requestable

  def save
    return false if invalid?

    RequestRequestable.call(requestable:, user:) if passed

    true
  end
end

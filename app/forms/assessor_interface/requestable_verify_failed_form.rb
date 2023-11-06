# frozen_string_literal: true

class AssessorInterface::RequestableVerifyFailedForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :note, :string
  validates :note, presence: true

  def save
    return false if invalid?

    VerifyRequestable.call(requestable:, user:, passed: false, note:)

    true
  end
end

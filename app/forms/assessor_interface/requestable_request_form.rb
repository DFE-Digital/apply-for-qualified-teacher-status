# frozen_string_literal: true

class AssessorInterface::RequestableRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :passed, :boolean
  validates :passed, presence: true

  delegate :application_form, :assessment, to: :requestable

  def save
    return false if invalid?

    unless requestable.requested?
      RequestRequestable.call(requestable:, user:)
      application_form.reload
      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    true
  end
end

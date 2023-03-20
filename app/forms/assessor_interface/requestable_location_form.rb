# frozen_string_literal: true

class AssessorInterface::RequestableLocationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :received, :boolean
  attribute :location_note, :string

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      requestable.location_note = location_note

      if received.present? && !requestable.received?
        ReceiveRequestable.call(requestable:, user:)
      elsif received.blank? && requestable.received?
        request_requestable
      else
        requestable.save!
      end
    end

    true
  end

  delegate :application_form, :assessment, to: :requestable

  private

  def request_requestable
    requestable.requested!
    TimelineEvent.requestable_received.where(requestable:).destroy_all
    ApplicationFormStatusUpdater.call(application_form:, user:)
  end
end

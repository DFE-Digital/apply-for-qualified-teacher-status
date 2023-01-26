# frozen_string_literal: true

class AssessorInterface::RequestableLocationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :requestable, :user
  validates :requestable, :user, presence: true

  attribute :received, :boolean

  attribute :location_note, :string
  validates :location_note, presence: true, if: -> { received.present? }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      requestable.update!(location_note:)

      if received.present? && !requestable.received?
        receive_professional_standing
      elsif received.blank? && requestable.received?
        request_professional_standing
      end

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    true
  end

  delegate :application_form, :assessment, to: :requestable

  private

  def receive_professional_standing
    requestable.received!

    TimelineEvent.create!(
      event_type: "requestable_received",
      application_form:,
      creator: user,
      requestable:,
    )
  end

  def request_professional_standing
    requestable.requested!

    TimelineEvent.requestable_received.where(requestable:).destroy_all
  end
end

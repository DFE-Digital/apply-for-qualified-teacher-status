# frozen_string_literal: true

class AssessorInterface::ProfessionalStandingRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :professional_standing_request, :user
  validates :professional_standing_request, :user, presence: true

  attribute :received, :boolean

  attribute :location_note, :string
  validates :location_note, presence: true, if: -> { received.present? }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      professional_standing_request.update!(location_note:)

      if received.present? && !professional_standing_request.received?
        receive_professional_standing
      elsif received.blank? && professional_standing_request.received?
        request_professional_standing
      end

      ApplicationFormStatusUpdater.call(application_form:, user:)
    end

    true
  end

  delegate :application_form, :assessment, to: :professional_standing_request

  private

  def receive_professional_standing
    professional_standing_request.received!

    TimelineEvent.create!(
      event_type: "requestable_received",
      application_form:,
      creator: user,
      requestable: professional_standing_request,
    )
  end

  def request_professional_standing
    professional_standing_request.requested!

    TimelineEvent
      .requestable_received
      .where(requestable: professional_standing_request)
      .destroy_all
  end
end

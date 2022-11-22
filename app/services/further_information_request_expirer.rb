# frozen_string_literal: true

class FurtherInformationRequestExpirer
  include ServicePattern
  FOUR_WEEK_COUNTRY_CODES = %w[AU CA GI NZ US].freeze

  def initialize(further_information_request:)
    @further_information_request = further_information_request
  end

  def call
    if expire_request?
      ActiveRecord::Base.transaction do
        further_information_request.failure_assessor_note =
          "Further information not supplied by deadline"
        further_information_request.passed = false
        further_information_request.expired!
        create_timeline_event
        decline_application
      end
    end

    further_information_request
  end

  private

  attr_reader :further_information_request
  delegate :assessment, to: :further_information_request
  delegate :application_form, to: :assessment
  delegate :region, to: :application_form
  delegate :country, to: :region

  def expire_request?
    further_information_request.requested? &&
      further_information_request.created_at < expire_if_older_than
  end

  def expire_if_older_than
    return 4.weeks.ago if FOUR_WEEK_COUNTRY_CODES.include?(country.code)

    6.weeks.ago
  end

  def decline_application
    UpdateAssessmentRecommendation.call(
      assessment:,
      user: "Expirer",
      new_recommendation: "decline",
    )
  end

  def create_timeline_event
    TimelineEvent.create!(
      application_form:,
      creator_name: "Expirer",
      further_information_request:,
      event_type: "further_information_request_expired",
    )
  end
end

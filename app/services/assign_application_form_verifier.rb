# frozen_string_literal: true

class AssignApplicationFormVerifier
  include ServicePattern

  def initialize(application_form:, verifier:)
    @application_form = application_form
    @verifier = verifier
  end

  def call
    return if application_form.verifier == verifier

    ActiveRecord::Base.transaction do
      application_form.update!(verifier:)

      CreateTimelineEvent.call(
        "verification_decision_made",
        application_form:,
        user: verifier,
      )
    end
  end

  private

  attr_reader :application_form, :verifier
end

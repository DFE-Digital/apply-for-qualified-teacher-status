# frozen_string_literal: true

class AssignApplicationFormVerifier
  include ServicePattern

  def initialize(application_form:, user:, verifier:)
    @application_form = application_form
    @user = user
    @verifier = verifier
  end

  def call
    return if application_form.verifier == verifier

    application_form.update!(verifier:)
  end

  private

  attr_reader :application_form, :user, :verifier
end

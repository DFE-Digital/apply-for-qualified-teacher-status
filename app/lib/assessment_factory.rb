# frozen_string_literal: true

class AssessmentFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    Assessment.create!(application_form:)
  end

  private

  attr_reader :application_form
end

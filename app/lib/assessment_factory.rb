# frozen_string_literal: true

class AssessmentFactory
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    sections = section_keys.map { |key| AssessmentSection.new(key:) }
    Assessment.create!(application_form:, sections:)
  end

  private

  attr_reader :application_form

  def section_keys
    %i[personal_information qualifications].tap do |keys|
      keys << :work_history if application_form.needs_work_history
      if application_form.needs_written_statement ||
           application_form.needs_registration_number
        keys << :professional_standing
      end
    end
  end
end

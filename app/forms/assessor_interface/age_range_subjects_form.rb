# frozen_string_literal: true

class AssessorInterface::AgeRangeSubjectsForm < AssessorInterface::AssessmentSectionForm
  attribute :age_range_min, :string
  attribute :age_range_max, :string
  attribute :age_range_note, :string

  validates :age_range_min,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
            }
  validates :age_range_max,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: :age_range_min,
            }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      existing_note = assessment.age_range_note

      note =
        if age_range_note != existing_note&.text
          CreateNote.call(application_form:, author: user, text: age_range_note)
        else
          existing_note
        end

      assessment.update!(age_range_min:, age_range_max:, age_range_note: note)

      super
    end

    true
  end

  class << self
    def initial_attributes(assessment_section)
      assessment = assessment_section.assessment
      super.merge(
        age_range_min: assessment.age_range_min,
        age_range_max: assessment.age_range_max,
        age_range_note: assessment.age_range_note&.text,
      )
    end

    def permittable_parameters
      args, kwargs = super
      args += %i[age_range_min age_range_max age_range_note]
      [args, kwargs]
    end
  end

  private

  def assessment
    @assessment ||= assessment_section.assessment
  end

  def application_form
    @application_form ||= assessment.application_form
  end
end

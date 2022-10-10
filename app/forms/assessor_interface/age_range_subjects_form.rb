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

  attribute :subject_1, :string
  attribute :subject_2, :string
  attribute :subject_3, :string
  attribute :subjects_note, :string

  validates :subject_1, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_age_range
      update_subjects
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
        subject_1: assessment.subjects.first,
        subject_2: assessment.subjects.second,
        subject_3: assessment.subjects.third,
        subjects_note: assessment.subjects_note&.text,
      )
    end

    def permittable_parameters
      args, kwargs = super
      args += %i[
        age_range_min
        age_range_max
        age_range_note
        subject_1
        subject_2
        subject_3
        subjects_note
      ]
      [args, kwargs]
    end
  end

  private

  def update_age_range
    note = find_or_create_note(assessment.age_range_note, age_range_note)
    assessment.update!(age_range_min:, age_range_max:, age_range_note: note)
  end

  def update_subjects
    subjects = [subject_1, subject_2, subject_3].compact_blank
    note = find_or_create_note(assessment.subjects_note, subjects_note)
    assessment.update!(subjects:, subjects_note: note)
  end

  def find_or_create_note(existing_note, new_text)
    if new_text != existing_note&.text
      if new_text.present?
        CreateNote.call(application_form:, author: user, text: new_text)
      end
    else
      existing_note
    end
  end

  def assessment
    @assessment ||= assessment_section.assessment
  end

  def application_form
    @application_form ||= assessment.application_form
  end
end

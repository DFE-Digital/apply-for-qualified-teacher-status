# frozen_string_literal: true

class AssessorInterface::CheckAgeRangeSubjectsForm < AssessorInterface::AssessmentSectionForm
  include AssessorInterface::AgeRangeSubjectsForm

  delegate :assessment, to: :assessment_section

  class << self
    def initial_attributes(assessment_section)
      assessment = assessment_section.assessment
      super.merge(
        age_range_min: assessment.age_range_min,
        age_range_max: assessment.age_range_max,
        age_range_note: assessment.age_range_note,
        subject_1: assessment.subjects.first,
        subject_2: assessment.subjects.second,
        subject_3: assessment.subjects.third,
        subjects_note: assessment.subjects_note,
      )
    end

    def permittable_parameters
      args, kwargs = super
      args += %i[
        age_range_min
        age_range_max
        age_range_note
        subject_1
        subject_1_raw
        subject_2
        subject_2_raw
        subject_3
        subject_3_raw
        subjects_note
      ]
      [args, kwargs]
    end
  end
end

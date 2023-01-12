# frozen_string_literal: true

class AssessorInterface::InductionRequiredForm < AssessorInterface::AssessmentSectionForm
  attribute :induction_required, :boolean

  validates :induction_required, inclusion: [true, false], if: :passed

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      assessment.update!(induction_required:)
      super
    end

    true
  end

  class << self
    def initial_attributes(assessment_section)
      assessment = assessment_section.assessment
      super.merge(induction_required: assessment.induction_required)
    end

    def permittable_parameters
      args, kwargs = super
      args += %i[induction_required]
      [args, kwargs]
    end
  end

  delegate :assessment, to: :assessment_section
end

# frozen_string_literal: true

class AssessorInterface::ScotlandFullRegistrationForm < AssessorInterface::InductionRequiredForm
  attribute :scotland_full_registration, :boolean

  validates :scotland_full_registration, inclusion: [true, false], if: :passed

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      assessment.update!(scotland_full_registration:)
      super
    end

    true
  end

  class << self
    def initial_attributes(assessment_section)
      assessment = assessment_section.assessment
      super.merge(
        scotland_full_registration: assessment.scotland_full_registration,
      )
    end

    def permittable_parameters
      args, kwargs = super
      args += %i[scotland_full_registration]
      [args, kwargs]
    end
  end

  delegate :assessment, to: :assessment_section
end

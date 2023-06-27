# frozen_string_literal: true

class AssessorInterface::AssessmentSectionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment_section, :user
  validates :assessment_section, :user, presence: true

  attribute :passed, :boolean
  validates :passed,
            inclusion: [true, false],
            unless: -> { assessment_section&.preliminary? }

  validates :selected_failure_reasons,
            presence: true,
            if: -> { passed == false }

  def selected_failure_reasons
    return {} if passed

    assessment_section
      .failure_reasons
      .each_with_object({}) do |failure_reason, memo|
        if send("#{failure_reason}_checked")
          memo[failure_reason] = send("#{failure_reason}_notes")
        end
      end
  end

  def save
    return false unless valid?

    params = {
      passed:
        (
          if assessment_section.preliminary?
            selected_failure_reasons.empty?
          else
            passed
          end
        ),
      selected_failure_reasons:,
    }

    UpdateAssessmentSection.call(assessment_section:, user:, params:)

    true
  end

  class << self
    def for_assessment_section(assessment_section)
      klass =
        Class.new(self) do
          mattr_accessor :preliminary

          def self.name
            "AssessorInterface::AssessmentSectionForm"
          end
        end

      klass.preliminary = assessment_section.preliminary?

      assessment_section.failure_reasons.each do |failure_reason|
        klass.attribute "#{failure_reason}_checked", :boolean

        if assessment_section.preliminary?
          klass.validates "#{failure_reason}_checked", inclusion: [true, false]
        end

        klass.attribute "#{failure_reason}_notes", :string

        if assessment_section.preliminary? ||
             FailureReasons.decline?(failure_reason:)
          next
        end
        klass.validates "#{failure_reason}_notes",
                        presence: true,
                        if: :"#{failure_reason}_checked"
      end

      klass
    end

    def initial_attributes(assessment_section)
      attributes = { assessment_section:, passed: assessment_section.passed }

      selected_failure_reasons_hash =
        assessment_section
          .selected_failure_reasons
          .each_with_object({}) do |failure_reason, memo|
            memo[failure_reason.key] = failure_reason.assessor_feedback
          end

      selected_failure_reasons_hash.each do |key, notes|
        attributes["#{key}_checked"] = true
        attributes["#{key}_notes"] = notes
      end

      if assessment_section.preliminary? && assessment_section.passed?
        remaining_failure_reasons =
          assessment_section.failure_reasons -
            selected_failure_reasons_hash.keys

        remaining_failure_reasons.each do |key|
          attributes["#{key}_checked"] = false
        end
      end

      attributes
    end

    def permit_parameters(params)
      args, kwargs = permittable_parameters
      params.permit(:passed, *args, **kwargs)
    end

    def permittable_parameters
      [permittable_args, permittable_kwargs]
    end

    private

    def permittable_args
      return attribute_names if preliminary

      attribute_names.filter { |attr_name| attr_name.ends_with?("_notes") }
    end

    def permittable_kwargs
      return {} if preliminary

      attribute_names
        .filter { |attr_name| attr_name.ends_with?("_checked") }
        .index_with { |_key| [] }
    end
  end
end

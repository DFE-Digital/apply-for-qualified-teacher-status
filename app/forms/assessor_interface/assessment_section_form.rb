# frozen_string_literal: true

class AssessorInterface::AssessmentSectionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment_section, :user
  validates :assessment_section, :user, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

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

  def selected_failure_reasons=(value)
    value.each do |failure_reason, notes|
      send("#{failure_reason}_checked=", true)
      send("#{failure_reason}_notes=", notes)
    end
  end

  def save
    return false unless valid?

    UpdateAssessmentSection.call(
      assessment_section:,
      user:,
      params: {
        passed:,
        selected_failure_reasons:,
      },
    )

    true
  end

  class << self
    def for_assessment_section(assessment_section)
      klass =
        Class.new(self) do
          def self.name
            "AssessorInterface::AssessmentSectionForm"
          end
        end

      assessment_section.failure_reasons.each do |failure_reason|
        klass.attribute "#{failure_reason}_checked", :boolean
        klass.attribute "#{failure_reason}_notes", :string
        next if FailureReasons.decline?(failure_reason:)

        klass.validates "#{failure_reason}_notes",
                        presence: true,
                        if: :"#{failure_reason}_checked"
      end

      klass
    end

    def initial_attributes(assessment_section)
      {
        assessment_section:,
        passed: assessment_section.passed,
        selected_failure_reasons: assessment_section.selected_failure_reasons,
      }
    end

    def permit_parameters(params)
      args, kwargs = permittable_parameters
      params.permit(:passed, *args, **kwargs)
    end

    protected

    def permittable_parameters
      args =
        attribute_names.filter { |attr_name| attr_name.ends_with?("_notes") }
      kwargs =
        attribute_names
          .filter { |attr_name| attr_name.ends_with?("_checked") }
          .index_with { |_key| [] }
      [args, kwargs]
    end
  end
end

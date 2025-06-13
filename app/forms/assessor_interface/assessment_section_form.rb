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
  validates :work_history,
            presence: true,
            if: -> do
              passed == false &&
                FailureReasons.chooses_work_history?(selected_failure_reasons)
            end

  def selected_failure_reasons
    return {} if passed

    work_histories =
      assessment_section
        .assessment
        .application_form
        .work_histories
        .teaching_role

    assessment_section
      .failure_reasons
      .each_with_object({}) do |failure_reason, memo|
        next unless send("#{failure_reason}_checked")
        memo[failure_reason] = { notes: send("#{failure_reason}_notes") }
        next unless FailureReasons.chooses_work_history?(failure_reason)
        memo[failure_reason][
          :work_histories
        ] = work_histories.filter do |work_history|
          send("#{failure_reason}_work_history_checked").include?(
            work_history.id.to_s,
          )
        end
      end
  end

  def save
    return false unless valid?

    AssessAssessmentSection.call(
      assessment_section,
      user:,
      passed:
        (
          if assessment_section.preliminary?
            selected_failure_reasons.empty?
          else
            passed
          end
        ),
      selected_failure_reasons:,
    )

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
        selected_failure_reason =
          assessment_section.selected_failure_reasons.find_by(
            key: failure_reason,
          )

        klass.attribute "#{failure_reason}_checked", :boolean

        if assessment_section.preliminary?
          klass.validates "#{failure_reason}_checked", inclusion: [true, false]
        end

        if FailureReasons.chooses_work_history?(failure_reason)
          klass.attribute "#{failure_reason}_work_history_checked"

          klass.validates "#{failure_reason}_work_history_checked",
                          presence: true,
                          if: :"#{failure_reason}_checked"
        elsif selected_failure_reason.present? &&
              selected_failure_reason.work_histories.present?
          klass.attribute "#{failure_reason}_work_history_checked"
        end

        klass.attribute "#{failure_reason}_notes", :string

        next if assessment_section.preliminary?

        next unless FailureReasons.requires_note?(failure_reason)

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
            memo[failure_reason.key] = {
              assessor_feedback: failure_reason.assessor_feedback,
              work_history_ids: failure_reason.work_histories.pluck(:id),
            }
          end

      selected_failure_reasons_hash.each do |key, notes|
        attributes["#{key}_checked"] = true
        attributes["#{key}_notes"] = notes[:assessor_feedback]
        if FailureReasons.chooses_work_history?(key) ||
             notes[:work_history_ids].present?
          attributes["#{key}_work_history_checked"] = notes[:work_history_ids]
        end
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
      params =
        params
          .permit(:passed, *args, **kwargs)
          .to_h
          .map do |key, value|
            if key.end_with?("work_history_checked")
              [key, value.compact_blank]
            else
              [key, value]
            end
          end
      params.to_h
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

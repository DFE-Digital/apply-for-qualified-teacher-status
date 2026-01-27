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

    assessment_section
      .failure_reasons
      .each_with_object({}) do |failure_reason, memo|
        next unless send("#{failure_reason}_checked")
        if FailureReasons.chooses_work_history?(failure_reason)
          memo[failure_reason] = {}
          memo[failure_reason][
            :work_history_failure_reasons
          ] = selected_work_histories_for_failure_reason(failure_reason)
        else
          memo[failure_reason] = {
            assessor_feedback: send("#{failure_reason}_notes"),
          }
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

  private

  def selected_work_histories_for_failure_reason(failure_reason)
    result =
      work_histories.map do |work_history|
        unless send("#{failure_reason}_work_history_#{work_history.id}_checked")
          next
        end

        {
          work_history_id: work_history.id,
          assessor_feedback:
            send("#{failure_reason}_work_history_#{work_history.id}_notes"),
        }
      end

    result.compact
  end

  def ensure_atleast_one_work_history_selected
    FailureReasons::WORK_HISTORY_REFERENCE_FAILURE_REASONS.each do |failure_reason|
      any_work_histories_selected =
        work_histories.any? do |work_history|
          send("#{failure_reason}_work_history_#{work_history.id}_checked")
        end

      next if any_work_histories_selected

      errors.add(
        :"#{failure_reason}_work_history_checked",
        :no_schools_selected,
      )
    end
  end

  def work_histories
    @work_histories ||=
      assessment_section
        .assessment
        .application_form
        .work_histories
        .teaching_role
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

      work_histories =
        assessment_section
          .assessment
          .application_form
          .work_histories
          .teaching_role

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

          work_histories.each do |work_history|
            klass.attribute "#{failure_reason}_work_history_#{work_history.id}_checked",
                            :boolean
          end

          klass.validate :ensure_atleast_one_work_history_selected,
                         if: :"#{failure_reason}_checked"
        elsif selected_failure_reason.present? &&
              selected_failure_reason.work_histories.present?
          work_histories.each do |work_history|
            klass.attribute "#{failure_reason}_work_history_#{work_history.id}_checked",
                            :boolean
          end
        end

        if FailureReasons.chooses_work_history?(failure_reason) ||
             (
               selected_failure_reason.present? &&
                 selected_failure_reason.work_histories.present?
             )
          work_histories.each do |work_history|
            klass.attribute "#{failure_reason}_work_history_#{work_history.id}_notes",
                            :string
          end
        else
          klass.attribute "#{failure_reason}_notes", :string
        end

        next if assessment_section.preliminary?

        next unless FailureReasons.requires_note?(failure_reason)

        if FailureReasons.chooses_work_history?(failure_reason)
          work_histories.each do |work_history|
            klass.validates "#{failure_reason}_work_history_#{work_history.id}_notes",
                            presence: {
                              message: "Enter a note to the applicant",
                            },
                            if:
                              :"#{failure_reason}_work_history_#{work_history.id}_checked"
          end
        else
          klass.validates "#{failure_reason}_notes",
                          presence: true,
                          if: :"#{failure_reason}_checked"
        end
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
              selected_failure_reasons_work_histories:
                failure_reason.selected_failure_reasons_work_histories,
            }
          end

      selected_failure_reasons_hash.each do |key, notes|
        attributes["#{key}_checked"] = true
        if FailureReasons.chooses_work_history?(key) ||
             notes[:selected_failure_reasons_work_histories].present?
          notes[
            :selected_failure_reasons_work_histories
          ].each do |wh_failure_reason|
            attributes[
              "#{key}_work_history_#{wh_failure_reason.work_history_id}_checked"
            ] = true
            attributes[
              "#{key}_work_history_#{wh_failure_reason.work_history_id}_notes"
            ] = wh_failure_reason.assessor_feedback || notes[:assessor_feedback]
          end
        else
          attributes["#{key}_notes"] = notes[:assessor_feedback]
        end
      end

      if assessment_section.preliminary? && assessment_section.assessed?
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
          .map { |key, value| [key, value] }
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

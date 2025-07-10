# frozen_string_literal: true

class AssessorInterface::PrioritisationWorkHistoryCheckForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :prioritisation_work_history_check
  validates :prioritisation_work_history_check, presence: true

  attribute :passed, :boolean
  validates :passed, inclusion: [true, false]

  validates :selected_prioritisation_failure_reasons,
            presence: true,
            if: -> { passed == false }

  def selected_prioritisation_failure_reasons
    return {} if passed

    prioritisation_work_history_check
      .failure_reasons
      .each_with_object({}) do |failure_reason, memo|
        next unless send("#{failure_reason}_checked")
        memo[failure_reason] = { notes: send("#{failure_reason}_notes") }
      end
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      prioritisation_work_history_check.update!(passed:)

      update_selected_prioritisation_failure_reasons
      update_assessment_started_at
    end

    true
  end

  class << self
    def for_prioritisation_work_history_check(prioritisation_work_history_check)
      klass =
        Class.new(self) do
          def self.name
            "AssessorInterface::PrioritisationWorkHistoryCheckForm"
          end
        end

      prioritisation_work_history_check.failure_reasons.each do |failure_reason|
        klass.attribute "#{failure_reason}_checked", :boolean
        klass.attribute "#{failure_reason}_notes", :string
      end

      klass
    end

    def initial_attributes(prioritisation_work_history_check)
      attributes = {
        prioritisation_work_history_check:,
        passed: prioritisation_work_history_check.passed,
      }

      selected_failure_reasons_hash =
        prioritisation_work_history_check
          .selected_prioritisation_failure_reasons
          .each_with_object({}) do |failure_reason, memo|
            memo[failure_reason.key] = {
              assessor_feedback: failure_reason.assessor_feedback,
            }
          end

      selected_failure_reasons_hash.each do |key, notes|
        attributes["#{key}_checked"] = true
        attributes["#{key}_notes"] = notes[:assessor_feedback]
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
      attribute_names.filter { |attr_name| attr_name.ends_with?("_notes") }
    end

    def permittable_kwargs
      attribute_names
        .filter { |attr_name| attr_name.ends_with?("_checked") }
        .index_with { |_key| [] }
    end
  end

  private

  delegate :assessment, to: :prioritisation_work_history_check

  def update_assessment_started_at
    assessment.update!(started_at: Time.zone.now) if assessment.started_at.nil?
  end

  def update_selected_prioritisation_failure_reasons
    selected_keys = selected_prioritisation_failure_reasons.keys

    prioritisation_work_history_check
      .selected_prioritisation_failure_reasons
      .where.not(key: selected_keys)
      .destroy_all

    selected_prioritisation_failure_reasons.each do |key, assessor_feedback|
      failure_reason =
        prioritisation_work_history_check.selected_prioritisation_failure_reasons.find_or_initialize_by(
          key:,
        )

      failure_reason.update!(assessor_feedback: assessor_feedback[:notes])
    end
  end
end

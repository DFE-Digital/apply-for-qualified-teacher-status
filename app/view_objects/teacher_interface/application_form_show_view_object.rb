# frozen_string_literal: true

class TeacherInterface::ApplicationFormShowViewObject
  def initialize(current_teacher:)
    @current_teacher = current_teacher
  end

  def teacher
    @current_teacher
  end

  def application_form
    @application_form ||= teacher.application_form
  end

  def assessment
    @assessment ||= application_form&.assessment
  end

  def further_information_request
    @further_information_request ||=
      assessment&.further_information_requests&.first
  end

  def started_at
    application_form.created_at.strftime("%e %B %Y")
  end

  def expires_at
    (application_form.created_at + 6.months).strftime("%e %B %Y")
  end

  def tasks
    hash = {}
    hash.merge!(about_you: %i[personal_information identification_document])
    hash.merge!(qualifications: %i[qualifications age_range subjects])

    if application_form.created_under_new_regulations? &&
         FeatureFlags::FeatureFlag.active?(:application_english_language)
      hash.merge!(english_language: %i[english_language])
    end

    hash.merge!(work_history: %i[work_history]) if needs_work_history

    if needs_written_statement || needs_registration_number
      hash.merge!(
        proof_of_recognition: [
          needs_registration_number ? :registration_number : nil,
          needs_written_statement ? :written_statement : nil,
        ].compact,
      )
    end

    hash
  end

  def task_statuses
    tasks.transform_values do |items|
      items.index_with { |item| application_form.send("#{item}_status") }
    end
  end

  def completed_task_sections
    task_statuses
      .filter { |_, statuses| statuses.values.all?("completed") }
      .map { |section, _| section }
  end

  def can_submit?
    completed_task_sections.count == tasks.count
  end

  def text_for_task_item(key)
    if key == :written_statement
      if application_form.teaching_authority_provides_written_statement
        I18n.t("application_form.tasks.items.written_statement.provide")
      else
        I18n.t("application_form.tasks.items.written_statement.upload")
      end
    else
      I18n.t("application_form.tasks.items.#{key}")
    end
  end

  def path_for_task_item(key)
    case key
    when :identification_document
      url_helpers.teacher_interface_application_form_document_path(
        application_form.identification_document,
      )
    when :written_statement
      if application_form.teaching_authority_provides_written_statement
        url_helpers.edit_teacher_interface_application_form_written_statement_path
      else
        url_helpers.teacher_interface_application_form_document_path(
          application_form.written_statement_document,
        )
      end
    when :work_history
      if FeatureFlags::FeatureFlag.active?(:application_work_history)
        url_helpers.teacher_interface_application_form_new_regs_work_histories_path
      else
        url_helpers.teacher_interface_application_form_work_histories_path
      end
    else
      begin
        url_helpers.send("teacher_interface_application_form_#{key}_path")
      rescue NoMethodError
        url_helpers.send("#{key}_teacher_interface_application_form_path")
      end
    end
  end

  def notes_from_assessors
    return [] if assessment.nil? || further_information_request.present?

    assessment.sections.filter_map do |section|
      next nil if section.selected_failure_reasons.empty?

      failure_reasons =
        section.selected_failure_reasons.map do |failure_reason|
          is_decline =
            FailureReasons.decline?(failure_reason: failure_reason.key)

          {
            key: failure_reason.key,
            is_decline:,
            assessor_feedback: failure_reason.assessor_feedback,
          }
        end

      failure_reasons =
        failure_reasons.sort_by do |failure_reason|
          [failure_reason[:is_decline] ? 0 : 1, failure_reason[:key]]
        end

      { assessment_section_key: section.key, failure_reasons: }
    end
  end

  def declined_cannot_reapply?
    return false if assessment.nil?

    assessment.sections.any? do |section|
      section.selected_failure_reasons.any? do |failure_reason|
        %w[authorisation_to_teach applicant_already_qts].include?(
          failure_reason.key,
        )
      end
    end
  end

  def show_further_information_request_expired_content?
    further_information_request.present? && further_information_request.expired?
  end

  private

  delegate :needs_work_history,
           :needs_written_statement,
           :needs_registration_number,
           to: :application_form,
           allow_nil: true

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end

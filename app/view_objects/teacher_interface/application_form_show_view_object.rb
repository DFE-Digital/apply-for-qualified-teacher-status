# frozen_string_literal: true

class TeacherInterface::ApplicationFormShowViewObject
  include RegionHelper

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

  def professional_standing_request
    @professional_standing_request ||= assessment&.professional_standing_request
  end

  def started_at
    application_form.created_at.strftime("%e %B %Y")
  end

  def expires_at
    (application_form.created_at + 6.months).strftime("%e %B %Y")
  end

  def task_list_sections
    @task_list_sections ||= [
      task_list_section(
        :about_you,
        %i[personal_information identification_document],
      ),
      task_list_section(:qualifications, %i[qualifications age_range subjects]),
      if application_form.created_under_new_regulations?
        task_list_section(:english_language, %i[english_language])
      end,
      if needs_work_history
        task_list_section(:work_history, %i[work_history])
      end,
      if needs_written_statement || needs_registration_number
        task_list_section(
          :proof_of_recognition,
          [
            needs_registration_number ? :registration_number : nil,
            needs_written_statement ? :written_statement : nil,
          ].compact,
        )
      end,
    ].compact
  end

  def completed_task_list_sections
    @completed_task_list_sections ||=
      task_list_sections.filter do |section|
        section[:items].all? { |item| item[:status] == "completed" }
      end
  end

  def can_submit?
    completed_task_list_sections.count == task_list_sections.count
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
    further_information_request&.expired? || false
  end

  def show_professional_standing_request_expired_content?
    professional_standing_request&.expired? || false
  end

  def request_further_information?
    further_information_request.present? &&
      further_information_request.requested? &&
      !further_information_request.received?
  end

  def request_professional_standing_certificate?
    teaching_authority_provides_written_statement &&
      professional_standing_request&.requested? &&
      (
        !requires_preliminary_check ||
          assessment&.all_preliminary_sections_passed?
      ) || false
  end

  delegate :region, to: :application_form

  private

  delegate :needs_work_history,
           :needs_written_statement,
           :needs_registration_number,
           :teaching_authority_provides_written_statement,
           :requires_preliminary_check,
           to: :application_form,
           allow_nil: true

  def task_list_section(key, item_keys)
    {
      title: I18n.t("application_form.tasks.sections.#{key}"),
      items: task_list_items(item_keys),
    }
  end

  def task_list_items(keys)
    keys.map do |key|
      {
        name: name_for_task_item(key),
        link: link_for_task_item(key),
        status: status_for_task_item(key),
      }
    end
  end

  def name_for_task_item(key)
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

  def link_for_task_item(key)
    case key
    when :identification_document
      [
        :teacher_interface,
        :application_form,
        application_form.identification_document,
      ]
    when :written_statement
      if application_form.teaching_authority_provides_written_statement
        %i[edit teacher_interface application_form written_statement]
      else
        [
          :teacher_interface,
          :application_form,
          application_form.written_statement_document,
        ]
      end
    when :work_history
      %i[teacher_interface application_form work_histories]
    else
      url_helpers = Rails.application.routes.url_helpers
      begin
        url_helpers.send("teacher_interface_application_form_#{key}_path")
      rescue NoMethodError
        url_helpers.send("#{key}_teacher_interface_application_form_path")
      end
    end
  end

  def status_for_task_item(key)
    application_form.send("#{key}_status")
  end
end

# frozen_string_literal: true

class TeacherInterface::ApplicationFormViewObject
  include RegionHelper

  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  delegate :assessment,
           :country,
           :region,
           :teacher,
           :passport_document_status,
           to: :application_form

  def passport_document_status_in_progress?
    passport_document_status == "in_progress"
  end

  def requires_passport_as_identity_proof?
    application_form.requires_passport_as_identity_proof
  end

  def teaching_authority_provides_written_statement?
    application_form.region.teaching_authority_provides_written_statement
  end

  def further_information_request
    @further_information_request ||=
      assessment&.latest_further_information_request
  end

  def started_at
    application_form.created_at.to_date.to_fs
  end

  def expires_at
    application_form.expires_at.to_date.to_fs
  end

  def task_list_sections
    [
      if requires_passport_as_identity_proof?
        task_list_section(
          :about_you,
          %i[personal_information passport_document],
        )
      else
        task_list_section(
          :about_you,
          %i[personal_information identification_document],
        )
      end,
      task_list_section(:qualifications, %i[qualifications age_range subjects]),
      unless application_form.created_under_old_regulations?
        task_list_section(:english_language, %i[english_language])
      end,
      if needs_work_history
        task_list_section(
          :work_history,
          [
            :work_history,
            (
              if includes_prioritisation_features &&
                   work_history_status_completed?
                :other_england_work_history
              end
            ),
          ].compact,
        )
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
    task_list_sections.filter do |section|
      section[:items].all? { |item| item[:status] == "completed" }
    end
  end

  def errored_task_list_sections
    task_list_sections.filter do |section|
      section[:items].any? { |item| item[:status] == "error" }
    end
  end

  def passport_expiry_date_expired?
    application_form.passport_expiry_date.present? &&
      application_form.passport_expiry_date < Date.current
  end

  def can_submit?
    completed_task_list_sections.count == task_list_sections.count
  end

  def declined_reasons
    if from_ineligible_country?
      country_name = CountryName.from_country(country)
      teaching_authority_name = region_teaching_authority_name(region)
      {
        "" => [
          {
            name:
              "As we are unable to verify professional standing documents with the #{teaching_authority_name} in " \
                "#{country_name}, we have removed #{country_name} from the list of eligible countries.\n\n" \
                "We need to be able to verify all documents submitted by " \
                "applicants with the relevant authorities. This is to ensure QTS requirements are applied " \
                "fairly and consistently to every teacher, regardless of the country they trained to teach in.",
          },
        ],
      }
    elsif assessment_declined_reasons.present?
      assessment_declined_reasons
    elsif further_information_request&.expired?
      {
        "" => [
          {
            name:
              I18n.t(
                "teacher_interface.application_forms.show.declined.failure_reasons.further_information_request_expired",
              ),
          },
        ],
      }
    elsif professional_standing_request&.expired?
      {
        "" => [
          {
            name:
              I18n.t(
                "teacher_interface.application_forms.show.declined.failure_reasons." \
                  "professional_standing_request_expired",
                certificate_name: region_certificate_name(region),
                teaching_authority_name: region_teaching_authority_name(region),
              ),
          },
        ],
      }
    else
      {}
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

  def from_ineligible_country?
    @from_ineligible_country ||= !country.eligibility_enabled
  end

  def request_further_information?
    further_information_request.present? &&
      further_information_request.requested? &&
      !further_information_request.received?
  end

  def preliminary_check_pending?
    return false if assessment.nil?

    requires_preliminary_check && !assessment.all_preliminary_sections_passed?
  end

  def request_professional_standing_certificate?
    teaching_authority_provides_written_statement &&
      professional_standing_request&.requested? &&
      !professional_standing_request&.received? &&
      (
        !requires_preliminary_check ||
          assessment&.all_preliminary_sections_passed?
      ) || false
  end

  def request_qualification_consent?
    return false if assessment.nil?

    consent_requests.requested.not_received.exists?
  end

  def qualification_consent_submitted?
    return false if assessment.nil? || consent_requests.empty?

    consent_requests.all?(&:received?)
  end

  def letter_of_professional_standing_received?
    return false if assessment.nil? || professional_standing_request.nil?

    professional_standing_request.received?
  end

  def show_work_history_under_submission_banner?
    application_form.qualification_changed_work_history_duration &&
      !work_history_duration.enough_for_submission?
  end

  def show_work_history_under_induction_banner?
    application_form.qualification_changed_work_history_duration &&
      !work_history_duration.enough_to_skip_induction?
  end

  private

  delegate :needs_work_history,
           :needs_written_statement,
           :needs_registration_number,
           :teaching_authority_provides_written_statement,
           :requires_preliminary_check,
           :includes_prioritisation_features,
           :work_history_status_completed?,
           to: :application_form

  delegate :consent_requests,
           :professional_standing_request,
           :qualification_requests,
           to: :assessment,
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
        name: task_list_item_name(key),
        link: task_list_item_link(key),
        status: task_list_item_status(key),
      }
    end
  end

  def task_list_item_name(key)
    if key == :written_statement
      if application_form.teaching_authority_provides_written_statement
        I18n.t("application_form.tasks.items.written_statement.provide")
      else
        I18n.t("application_form.tasks.items.written_statement.upload")
      end
    elsif key == :registration_number
      if CountryCode.ghana?(application_form.country.code)
        I18n.t("application_form.tasks.items.registration_number.ghana")
      else
        I18n.t("application_form.tasks.items.registration_number.other")
      end
    else
      I18n.t("application_form.tasks.items.#{key}")
    end
  end

  def task_list_item_link(key)
    case key
    when :identification_document
      [
        :teacher_interface,
        :application_form,
        application_form.identification_document,
      ]
    when :passport_document
      %i[teacher_interface application_form passport_document]
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
    when :other_england_work_history
      %i[teacher_interface application_form other_england_work_histories]
    else
      url_helpers = Rails.application.routes.url_helpers
      begin
        url_helpers.send("teacher_interface_application_form_#{key}_path")
      rescue NoMethodError
        url_helpers.send("#{key}_teacher_interface_application_form_path")
      end
    end
  end

  def task_list_item_status(key)
    application_form.send("#{key}_status")
  end

  def assessment_declined_reasons
    @assessment_declined_reasons ||=
      begin
        reasons = {}

        if (note = assessment&.recommendation_assessor_note).present?
          reasons.merge!({ "" => [{ name: note }] })
        end

        if assessment.present? && further_information_request.nil?
          reasons.merge!(selected_failure_reasons_declined_reasons)
        end

        reasons
      end
  end

  def selected_failure_reasons_declined_reasons
    assessment
      .sections
      .each_with_object({}) do |section, hash|
        next if section.selected_failure_reasons.empty?

        sorted_reasons =
          section.selected_failure_reasons.sort_by do |failure_reason|
            is_decline = FailureReasons.decline?(failure_reason.key)

            [is_decline ? 0 : 1, failure_reason.key]
          end

        reasons =
          sorted_reasons.map do |failure_reason|
            title =
              I18n.t(
                failure_reason.key,
                scope: %i[
                  teacher_interface
                  application_forms
                  show
                  declined
                  failure_reasons
                ],
              )

            if (
                 assessor_feedback = failure_reason.assessor_feedback
               ).present? && FailureReasons.decline?(failure_reason.key)
              { name: title, assessor_note: assessor_feedback }
            else
              { name: title }
            end
          end

        hash[section.key.humanize] = reasons
      end
  end

  def work_history_duration
    @work_history_duration ||=
      WorkHistoryDuration.for_application_form(application_form)
  end
end

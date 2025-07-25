# frozen_string_literal: true

class ApplicationFormSectionStatusUpdater
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.update!(
      personal_information_status:,
      identification_document_status:,
      passport_document_status:,
      qualifications_status:,
      age_range_status:,
      subjects_status:,
      english_language_status:,
      work_history_status:,
      other_england_work_history_status:,
      registration_number_status:,
      written_statement_status:,
    )
  end

  private

  attr_reader :application_form

  delegate :given_names,
           :family_name,
           :date_of_birth,
           :has_alternative_name,
           :alternative_given_names,
           :alternative_family_name,
           :name_change_document,
           :identification_document,
           :qualifications,
           :teaching_qualification,
           :age_range_min,
           :age_range_max,
           :subjects,
           :english_language_citizenship_exempt,
           :english_language_qualification_exempt,
           :english_language_proof_method,
           :english_language_medium_of_instruction_document,
           :english_for_speakers_of_other_languages_document,
           :english_language_proficiency_document,
           :english_language_provider,
           :english_language_provider_other,
           :english_language_provider_reference,
           :has_work_history,
           :has_other_england_work_history,
           :work_histories,
           :registration_number,
           :passport_country_of_issue_code,
           :passport_document,
           :passport_expiry_date,
           :teaching_authority_provides_written_statement,
           :written_statement_confirmation,
           :written_statement_document,
           to: :application_form

  def personal_information_status
    values = [given_names, family_name, date_of_birth]

    if has_alternative_name.nil?
      values.append(nil)
    elsif has_alternative_name
      values.append(
        alternative_given_names,
        alternative_family_name,
        name_change_document&.completed?,
      )
    else
      values.append(true)
    end

    status_for_values(*values)
  end

  def identification_document_status
    identification_document.status
  end

  def passport_document_status
    if passport_expiry_date.nil? && passport_country_of_issue_code.nil? &&
         (passport_document.nil? || passport_document.uploads.empty?)
      return :not_started
    end

    if passport_document.any_unsafe_to_link?
      :error
    elsif passport_document.completed? && passport_expiry_date.present? &&
          passport_country_of_issue_code.present? &&
          passport_expiry_date >= Date.current
      :completed
    else
      :in_progress
    end
  end

  def qualifications_status
    return :not_started if qualifications.empty?

    part_of_degree = application_form.teaching_qualification_part_of_degree
    if part_of_degree.nil? || (!part_of_degree && qualifications.count == 1)
      return :in_progress
    end

    if qualifications.any?(&:any_documents_unsafe_to_link?)
      :error
    elsif qualifications.all?(&:complete?)
      :completed
    else
      :in_progress
    end
  end

  def age_range_status
    status_for_values(age_range_min, age_range_max)
  end

  def subjects_status
    return :not_started if subjects.empty?
    return :in_progress if subjects.compact_blank.empty?
    :completed
  end

  def english_language_status
    if english_language_citizenship_exempt ||
         english_language_qualification_exempt
      return :completed
    end

    case english_language_proof_method
    when "medium_of_instruction"
      if (status = english_language_medium_of_instruction_document.status) !=
           "not_started"
        status
      else
        "in_progress"
      end
    when "esol"
      if (status = english_for_speakers_of_other_languages_document.status) !=
           "not_started"
        status
      else
        "in_progress"
      end
    when "provider"
      if english_language_provider_other
        if (status = english_language_proficiency_document.status) !=
             "not_started"
          status
        else
          "in_progress"
        end
      else
        status_for_values(
          english_language_proof_method,
          english_language_provider,
          english_language_provider_reference,
        )
      end
    else
      if [
           english_language_citizenship_exempt,
           english_language_qualification_exempt,
         ].all?(&:nil?)
        :not_started
      else
        :in_progress
      end
    end
  end

  def work_history_status
    teaching_work_histories = work_histories.teaching_role

    all_work_histories_complete = teaching_work_histories.all?(&:complete?)

    if application_form.created_under_old_regulations?
      return :not_started if has_work_history.nil?

      if !has_work_history ||
           (!teaching_work_histories.empty? && all_work_histories_complete)
        :completed
      else
        :in_progress
      end
    else
      return :not_started if teaching_work_histories.empty?
      return :in_progress unless all_work_histories_complete

      enough_for_submission =
        WorkHistoryDuration.for_application_form(
          application_form,
        ).enough_for_submission?

      enough_for_submission ? :completed : :in_progress
    end
  end

  def other_england_work_history_status
    other_england_work_histories = work_histories.other_england_educational_role

    all_work_histories_complete =
      !other_england_work_histories.empty? &&
        other_england_work_histories.all?(&:complete?)

    return :not_started if has_other_england_work_history.nil?
    if !has_other_england_work_history || all_work_histories_complete
      return :completed
    end

    :in_progress
  end

  def registration_number_status
    if CountryCode.ghana?(application_form.country.code)
      if registration_number.present?
        registration_number_validator =
          RegistrationNumberValidators::Ghana.new(registration_number:)
        registration_number_validator.valid? ? :completed : :in_progress
      else
        :not_started
      end
    else
      registration_number.nil? ? :not_started : :completed
    end
  end

  def written_statement_status
    if teaching_authority_provides_written_statement
      written_statement_confirmation ? :completed : :not_started
    else
      written_statement_document.status
    end
  end

  def status_for_values(*values)
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end
end

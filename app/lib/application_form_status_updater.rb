# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.update!(
      personal_information_status:,
      identification_document_status:,
      qualifications_status:,
      age_range_status:,
      subjects_status:,
      english_language_status:,
      work_history_status:,
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
           :english_language_provider,
           :english_language_provider_reference,
           :has_work_history,
           :work_histories,
           :registration_number,
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
        name_change_document&.uploaded?,
      )
    else
      values.append(true)
    end

    status_for_values(*values)
  end

  def identification_document_status
    identification_document.uploaded? ? :completed : :not_started
  end

  def qualifications_status
    return :not_started if qualifications.empty?

    part_of_university_degree = teaching_qualification.part_of_university_degree
    if part_of_university_degree.nil? ||
         (!part_of_university_degree && qualifications.count == 1)
      return :in_progress
    end

    qualifications.all?(&:complete?) ? :completed : :in_progress
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
      if english_language_medium_of_instruction_document.uploaded?
        :completed
      else
        :in_progress
      end
    when "provider"
      status_for_values(
        english_language_proof_method,
        english_language_provider,
        english_language_provider_reference,
      )
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
    all_work_histories_complete =
      work_histories.all? do |work_history|
        work_history_complete?(work_history)
      end

    if work_history_feature_active?
      return :not_started if work_histories.empty?
      return :in_progress unless all_work_histories_complete

      months_count = WorkHistoryDuration.new(application_form:).count_months
      return :in_progress unless months_count >= 9

      :completed
    else
      return :not_started if has_work_history.nil?

      if !has_work_history ||
           (!work_histories.empty? && all_work_histories_complete)
        :completed
      else
        :in_progress
      end
    end
  end

  def work_history_complete?(work_history)
    values = [
      work_history.school_name,
      work_history.city,
      work_history.country_code,
      work_history.job,
      work_history.contact_name,
      work_history.contact_email,
      work_history.start_date,
      work_history.still_employed,
    ]

    if work_history.still_employed == false
      values.pop
      values.append(work_history.end_date)
    end

    if work_history_feature_active?
      values += [work_history.hours_per_week, work_history.contact_job]
    end

    values.all?(&:present?)
  end

  def registration_number_status
    registration_number.nil? ? :not_started : :completed
  end

  def written_statement_status
    completed =
      if teaching_authority_provides_written_statement
        written_statement_confirmation
      else
        written_statement_document.uploaded?
      end

    completed ? :completed : :not_started
  end

  def status_for_values(*values)
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end

  def work_history_feature_active?
    FeatureFlags::FeatureFlag.active?(:application_work_history)
  end
end

# frozen_string_literal: true

class ApplicationFormStatusUpdater
  include ServicePattern

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    application_form.personal_information_status = personal_information_status
    application_form.identification_document_status =
      identification_document_status
    application_form.qualifications_status = qualifications_status
    application_form.age_range_status = age_range_status
    application_form.subjects_status = subjects_status
    application_form.work_history_status = work_history_status
    application_form.registration_number_status = registration_number_status
    application_form.written_statement_status = written_statement_status
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
           :has_work_history,
           :work_histories,
           :registration_number,
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

    all_complete =
      qualifications.all? do |qualification|
        qualification_complete?(qualification)
      end

    all_complete ? :completed : :in_progress
  end

  def qualification_complete?(qualification)
    values = [
      qualification.title,
      qualification.institution_name,
      qualification.institution_country_code,
      qualification.start_date,
      qualification.complete_date,
      qualification.certificate_date,
      qualification.certificate_document.uploaded?,
      qualification.transcript_document.uploaded?,
    ]

    if qualification.is_teaching_qualification? &&
         qualification.part_of_university_degree != false
      values.push(qualification.part_of_university_degree)
    end

    values.all?(&:present?)
  end

  def age_range_status
    status_for_values(age_range_min, age_range_max)
  end

  def subjects_status
    return :not_started if subjects.empty?
    return :in_progress if subjects.compact_blank.empty?
    :completed
  end

  def work_history_status
    return :not_started if has_work_history.nil?

    if !has_work_history ||
         (
           !work_histories.empty? &&
             work_histories.all? do |work_history|
               work_history_complete?(work_history)
             end
         )
      return :completed
    end

    :in_progress
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

    values.all?(&:present?)
  end

  def registration_number_status
    registration_number.nil? ? :not_started : :completed
  end

  def written_statement_status
    written_statement_document.uploaded? ? :completed : :not_started
  end

  def status_for_values(*values)
    return :not_started if values.all?(&:blank?)
    return :completed if values.all?(&:present?)
    :in_progress
  end
end

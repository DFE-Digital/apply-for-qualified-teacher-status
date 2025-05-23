# frozen_string_literal: true

class UpdateTeachingQualification
  include ServicePattern

  def initialize(
    qualification:,
    user:,
    title: nil,
    institution_name: nil,
    certificate_date: nil,
    complete_date: nil,
    start_date: nil,
    teaching_qualification_part_of_degree: nil
  )
    @qualification = qualification
    @user = user
    @title = title
    @institution_name = institution_name
    @certificate_date = certificate_date
    @complete_date = complete_date
    @start_date = start_date
    @teaching_qualification_part_of_degree =
      teaching_qualification_part_of_degree
  end

  def call
    unless qualification.is_teaching?
      raise NotTeachingQualification,
            "Qualification is not the teaching qualification and cannot be updated"
    end

    unless application_form.not_started_stage? ||
             application_form.assessment_stage? ||
             application_form.review_stage?
      raise InvalidState,
            "Teaching qualification can only be update while the application is in assessment or review stage"
    end

    ActiveRecord::Base.transaction do
      if certificate_date.present?
        change_value("certificate_date", certificate_date)
      end

      unless has_enough_work_history_for_submission?
        raise InvalidWorkHistoryDuration
      end

      change_value("start_date", start_date) if start_date.present?
      change_value("complete_date", complete_date) if complete_date.present?

      change_value("title", title) if title.present?
      if institution_name.present?
        change_value("institution_name", institution_name)
      end

      unless teaching_qualification_part_of_degree.nil?
        change_value(
          "teaching_qualification_part_of_degree",
          teaching_qualification_part_of_degree,
        )
      end

      if application_form.review_stage?
        UpdateAssessmentInductionRequired.call(assessment:)
      end
    end
  end

  private

  attr_reader :qualification,
              :user,
              :title,
              :institution_name,
              :certificate_date,
              :complete_date,
              :start_date,
              :teaching_qualification_part_of_degree

  delegate :application_form, to: :qualification
  delegate :assessment, to: :application_form

  def change_value(column_name, new_value)
    if column_name == "teaching_qualification_part_of_degree"
      old_value = application_form.teaching_qualification_part_of_degree

      application_form.update!(teaching_qualification_part_of_degree: new_value)
    else
      old_value = qualification.send(column_name)

      qualification.update!(column_name => new_value)
    end

    if column_name.in?(%w[start_date complete_date certificate_date])
      create_timeline_event(
        column_name,
        old_value.to_fs(:month_and_year),
        new_value.to_fs(:month_and_year),
      )
    elsif column_name == "teaching_qualification_part_of_degree"
      parsed_old_value = old_value ? "Yes" : "No"
      parsed_new_value = new_value ? "Yes" : "No"

      create_timeline_event(column_name, parsed_old_value, parsed_new_value)
    else
      create_timeline_event(column_name, old_value, new_value)
    end
  end

  def create_timeline_event(column_name, old_value, new_value)
    CreateTimelineEvent.call(
      "information_changed",
      application_form:,
      user:,
      qualification:,
      column_name:,
      old_value:,
      new_value:,
    )
  end

  def has_enough_work_history_for_submission?
    WorkHistoryDuration.for_application_form(
      application_form.reload,
    ).enough_for_submission?
  end

  class InvalidState < StandardError
  end

  class NotTeachingQualification < StandardError
  end

  class InvalidWorkHistoryDuration < StandardError
  end
end

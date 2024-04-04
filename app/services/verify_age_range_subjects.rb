# frozen_string_literal: true

class VerifyAgeRangeSubjects
  include ServicePattern

  def initialize(
    assessment:,
    user:,
    age_range_min:,
    age_range_max:,
    age_range_note:,
    subjects:,
    subjects_note:
  )
    @assessment = assessment
    @user = user
    @age_range_min = age_range_min
    @age_range_max = age_range_max
    @age_range_note = age_range_note.presence || ""
    @subjects = subjects
    @subjects_note = subjects_note.presence || ""
  end

  def call
    ActiveRecord::Base.transaction do
      assessment.update!(
        age_range_min:,
        age_range_max:,
        age_range_note:,
        subjects:,
        subjects_note:,
      )

      create_timeline_event
    end
  end

  private

  attr_reader :assessment,
              :user,
              :age_range_min,
              :age_range_max,
              :age_range_note,
              :subjects,
              :subjects_note

  def create_timeline_event
    CreateTimelineEvent.call(
      "age_range_subjects_verified",
      application_form:,
      user:,
      assessment:,
      age_range_min:,
      age_range_max:,
      age_range_note:,
      subjects:,
      subjects_note:,
    )
  end

  delegate :application_form, to: :assessment
end

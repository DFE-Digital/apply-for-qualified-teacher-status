# frozen_string_literal: true

module AssessorInterface::AgeRangeSubjectsForm
  extend ActiveSupport::Concern

  included do
    attribute :age_range_min, :integer
    attribute :age_range_max, :integer
    attribute :age_range_note, :string

    validates :age_range_min,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                allow_nil: true,
              }
    validates :age_range_max,
              presence: true,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: :age_range_min,
                allow_nil: true,
              }

    attribute :subject_1, :string
    attribute :subject_1_raw, :string
    attribute :subject_2, :string
    attribute :subject_2_raw, :string
    attribute :subject_3, :string
    attribute :subject_3_raw, :string
    attribute :subjects_note, :string

    validates :subject_1, presence: true
    validates :subject_1_raw, presence: true
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_age_range
      update_subjects
      create_timeline_event
      super if defined?(super)
    end

    true
  end

  private

  def update_age_range
    note = age_range_note.presence || ""
    assessment.update!(age_range_min:, age_range_max:, age_range_note: note)
  end

  def update_subjects
    subjects = [
      subject_1_raw.present? ? subject_1 : "",
      subject_2_raw.present? ? subject_2 : "",
      subject_3_raw.present? ? subject_3 : "",
    ].compact_blank
    note = subjects_note.presence || ""
    assessment.update!(subjects:, subjects_note: note)
  end

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: :age_range_subjects_verified,
      application_form:,
      assessment:,
      age_range_min: assessment.age_range_min,
      age_range_max: assessment.age_range_max,
      age_range_note: assessment.age_range_note,
      subjects: assessment.subjects,
      subjects_note: assessment.subjects_note,
    )
  end

  delegate :application_form, to: :assessment
end

# frozen_string_literal: true

class AssessorInterface::AgeRangeSubjectsForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :assessment, :user
  validates :assessment, :user, presence: true

  attribute :age_range_min, :string
  attribute :age_range_max, :string
  attribute :age_range_note, :string

  validates :age_range_min,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
            }
  validates :age_range_max,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: :age_range_min,
            }

  attribute :subject_1, :string
  attribute :subject_2, :string
  attribute :subject_3, :string
  attribute :subjects_note, :string

  validates :subject_1, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_age_range
      update_subjects
      create_timeline_event
    end

    true
  end

  private

  def update_age_range
    note = age_range_note.presence || ""
    assessment.update!(age_range_min:, age_range_max:, age_range_note: note)
  end

  def update_subjects
    subjects = [subject_1, subject_2, subject_3].compact_blank
    note = subjects_note.presence || ""
    assessment.update!(subjects:, subjects_note: note)
  end

  def create_timeline_event
    TimelineEvent.create!(
      creator: user,
      event_type: :age_range_subjects_verified,
      application_form:,
      assessment:,
    )
  end

  delegate :application_form, to: :assessment
end

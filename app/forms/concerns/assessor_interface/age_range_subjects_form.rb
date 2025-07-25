# frozen_string_literal: true

module AssessorInterface::AgeRangeSubjectsForm
  extend ActiveSupport::Concern

  included do
    attribute :age_range_min, :integer
    attribute :age_range_max, :integer
    attribute :age_range_note, :string

    validates :age_range_note,
              presence: true,
              if: :age_range_changed_from_application_form?
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
                less_than_or_equal_to: 19,
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

    validate :subject_1_is_present
  end

  def save
    return false unless valid?

    subjects = [
      subject_1_raw.present? ? subject_1 : "",
      subject_2_raw.present? ? subject_2 : "",
      subject_3_raw.present? ? subject_3 : "",
    ].compact_blank

    ActiveRecord::Base.transaction do
      VerifyAgeRangeSubjects.call(
        assessment:,
        user:,
        age_range_min:,
        age_range_max:,
        age_range_note:,
        subjects:,
        subjects_note:,
      )

      super if defined?(super)
    end

    true
  end

  private

  delegate :application_form, to: :assessment

  def age_range_changed_from_application_form?
    return unless assessment

    application_form.age_range_min != age_range_min ||
      application_form.age_range_max != age_range_max
  end

  def subject_1_is_present
    return if subject_1.present? && subject_1_raw.present?

    errors.add(:subject_1, :blank)
  end
end

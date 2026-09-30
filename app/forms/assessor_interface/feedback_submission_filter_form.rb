# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :submitted_at_after, :submitted_at_before

  validate :submitted_at_after_parts_present
  validate :submitted_at_before_parts_present
  validates :submitted_at_after,
            date: true,
            if: -> { date_parts_present?(:submitted_at_after) }
  validates :submitted_at_before,
            date: true,
            if: -> { date_parts_present?(:submitted_at_before) }
  validates_with DateComparisonValidator,
                 earlier_field: :submitted_at_after,
                 later_field: :submitted_at_before,
                 allow_equal: true

  private

  def submitted_at_after_parts_present
    validate_date_parts(:submitted_at_after)
  end

  def submitted_at_before_parts_present
    validate_date_parts(:submitted_at_before)
  end

  def validate_date_parts(attribute)
    value = public_send(attribute)

    if value.blank?
      errors.add(attribute, :blank)
      return
    end

    missing_date_parts(value).each do |date_part|
      errors.add(attribute, :"missing_#{date_part}")
    end
  end

  def missing_date_parts(value)
    { day: 3, month: 2, year: 1 }.filter_map do |date_part, index|
      date_part if value[index].blank?
    end
  end

  def date_parts_present?(attribute)
    value = public_send(attribute)
    value.present? && missing_date_parts(value).empty?
  end
end

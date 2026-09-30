# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :submitted_at_after, :submitted_at_before

  validate :submitted_at_after_valid
  validate :submitted_at_before_valid
  validates_with DateComparisonValidator,
                 earlier_field: :submitted_at_after,
                 later_field: :submitted_at_before,
                 allow_equal: true

  private

  def submitted_at_after_valid
    validate_date(:submitted_at_after)
  end

  def submitted_at_before_valid
    validate_date(:submitted_at_before)
  end

  def validate_date(attribute)
    value = public_send(attribute)

    if value.blank?
      errors.add(attribute, :blank)
      return
    end

    missing_date_parts(value).each do |date_part|
      errors.add(attribute, :"missing_#{date_part}")
    end
    return if errors.include?(attribute)

    date = parsed_date(value)
    if date.nil?
      errors.add(attribute, :invalid)
    elsif date > Date.current
      errors.add(attribute, :future)
    end
  end

  def missing_date_parts(value)
    { day: 3, month: 2, year: 1 }.filter_map do |date_part, index|
      date_part if value[index].blank?
    end
  end

  def parsed_date(value)
    Date.new(value[1], value[2], value[3])
  rescue Date::Error
    nil
  end
end

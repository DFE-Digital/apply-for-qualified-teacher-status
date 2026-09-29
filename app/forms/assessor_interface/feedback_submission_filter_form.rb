# frozen_string_literal: true

class AssessorInterface::FeedbackSubmissionFilterForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :submitted_at_after, :submitted_at_before

  validate :submitted_at_after_valid
  validate :submitted_at_before_valid
  validate :submitted_at_before_after_submitted_at_after

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

  def submitted_at_before_after_submitted_at_after
    return if errors.any?

    after_date = parsed_date(submitted_at_after)
    before_date = parsed_date(submitted_at_before)
    return if after_date.nil? || before_date.nil? || before_date > after_date

    errors.add(:submitted_at_before, :comparison)
  end

  def parsed_date(value)
    Date.new(value[1], value[2], value[3])
  rescue Date::Error
    nil
  end
end

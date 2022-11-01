# frozen_string_literal: true

class DateComparisonValidator < ActiveModel::Validator
  def initialize(options)
    super
    @earlier_field = options[:earlier_field] || :start_date
    @later_field = options[:later_field] || :end_date
  end

  def validate(record)
    earlier = DateValidator.parse(record.send(earlier_field))
    later = DateValidator.parse(record.send(later_field))
    return unless earlier.present? && later.present?

    record.errors.add(later_field, :comparison) if earlier >= later
  end

  private

  attr_reader :earlier_field, :later_field
end

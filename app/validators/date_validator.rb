# frozen_string_literal: true

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless DateValidator.date_params_present?(value)
      record.errors.add(attribute, :blank) && return
    end

    date = DateValidator.parse(value)

    record.errors.add(attribute, :invalid) && return if date.nil?

    record.errors.add(attribute, :future) if date >= Time.zone.now
  end

  def self.parse(date_hash)
    return nil unless date_params_present?(date_hash)
    return nil unless date_params_valid?(date_hash)

    begin
      Date.new(date_hash[1], date_hash[2], date_hash[3])
    rescue Date::Error
      nil
    end
  end

  def self.date_params_present?(date_hash)
    return false if date_hash.blank?
    date_hash.compact.length == 3
  end

  def self.date_params_valid?(date_hash)
    date_hash[1].to_s.length == 4 && date_hash[2].to_s.length <= 2 &&
      date_hash[3].to_s.length <= 2
  end
end

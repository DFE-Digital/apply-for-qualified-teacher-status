# frozen_string_literal: true

require "active_support/testing/time_helpers"

class FakeData::DateGenerator
  include ActiveSupport::Testing::TimeHelpers

  def initialize
    @date = Faker::Time.between(from: 6.months.ago, to: 3.months.ago)
  end

  attr_reader :date

  def next_short
    @date = Faker::Time.between(from: date, to: date + 1.hour)
  end

  def next_long
    @date = Faker::Time.between(from: date, to: date + 2.weeks)
  end

  def travel_to_date(&block)
    travel_to(date, &block)
  end

  def travel_to_next_short(&block)
    travel_to(next_short, &block)
  end

  def travel_to_next_long(&block)
    travel_to(next_long, &block)
  end
end

# frozen_string_literal: true

module FormatUkTimeHelper
  def format_uk_time(time)
    return "" if time.nil?
    time.in_time_zone('London').strftime("%Y-%m-%d %H:%M:%S")
  end
end

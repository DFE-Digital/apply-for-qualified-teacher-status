# frozen_string_literal: true

module FormatTimeHelper
  def format_human_readable_uk_time(time)
    return "" if time.nil?
    time.in_time_zone("London").strftime("%-d %B %Y at %-l:%M %P")
  end
end

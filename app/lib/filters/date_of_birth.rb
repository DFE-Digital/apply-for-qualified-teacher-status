# frozen_string_literal: true

module Filters
  class DateOfBirth < Base
    def apply
      new_scope = scope
      
      if date_of_birth.present?
        new_scope = new_scope.where("DATE(date_of_birth) = ?", date_of_birth)
      end
      
      new_scope
    end

    private

    def date_of_birth
      Date.new(
        params["date_of_birth(1i)"].to_i,
        params["date_of_birth(2i)"].to_i,
        params["date_of_birth(3i)"].to_i,
      )
    rescue Date::Error
      nil
    end
  end
end

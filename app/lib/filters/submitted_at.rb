# frozen_string_literal: true

module Filters
  class SubmittedAt < Base
    def apply
      new_scope = scope

      if submitted_at_after.present?
        new_scope =
          new_scope.where("DATE(submitted_at) >= ?", submitted_at_after)
      end

      if submitted_at_before.present?
        new_scope =
          new_scope.where("DATE(submitted_at) <= ?", submitted_at_before)
      end

      new_scope
    end

    private

    def submitted_at_after
      Date.new(
        params["submitted_at_after(1i)"].to_i,
        params["submitted_at_after(2i)"].to_i,
        params["submitted_at_after(3i)"].to_i,
      )
    rescue Date::Error
      nil
    end

    def submitted_at_before
      Date.new(
        params["submitted_at_before(1i)"].to_i,
        params["submitted_at_before(2i)"].to_i,
        params["submitted_at_before(3i)"].to_i,
      )
    rescue Date::Error
      nil
    end
  end
end

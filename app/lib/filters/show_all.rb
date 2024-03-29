# frozen_string_literal: true

module Filters
  class ShowAll < Base
    def apply
      unless show_all?
        ninety_days_ago = 90.days.ago
        return(
          scope.where(
            "(awarded_at >= :ninety_days OR awarded_at IS NULL)
          AND (declined_at >= :ninety_days OR declined_at IS NULL)
          AND (withdrawn_at >= :ninety_days OR withdrawn_at IS NULL)",
            ninety_days: ninety_days_ago,
          )
        )
      end

      scope
    end

    private

    def show_all?
      ActiveModel::Type::Boolean.new.cast(params[:show_all])
    end
  end
end

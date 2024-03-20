module Filters
  class ShowAllApplications < Base
    def apply
      unless show_all_applications.include?("show_all")
        ninety_days_ago = 90.days.ago
        new_scope =
          scope.where(
            "awarded_at >= :ninety_days OR declined_at >= :ninety_days OR withdrawn_at >= :ninety_days",
            ninety_days: ninety_days_ago,
          )
        return new_scope
      end

      scope
    end

    private

    def show_all_applications
      Array(params[:display]).compact_blank
    end
  end
end

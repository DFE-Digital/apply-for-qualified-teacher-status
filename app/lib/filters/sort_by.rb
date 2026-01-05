# frozen_string_literal: true

module Filters
  class SortBy < Base
    def apply
      case params[:sort_by]
      when "submitted_at_asc"
        scope.order(submitted_at: :asc)
      else
        scope.order(submitted_at: :desc)
      end
    end
  end
end

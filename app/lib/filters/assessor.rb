# frozen_string_literal: true

module Filters
  class Assessor < Base
    def apply
      return scope if assessor_ids.empty?

      scope.where(assessor_id: assessor_ids)
    end

    private

    def assessor_ids
      Array(params[:assessor_ids])
    end
  end
end

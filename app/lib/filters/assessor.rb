# frozen_string_literal: true

module Filters
  class Assessor < Base
    def apply
      return scope if assessor_ids.empty?

      scope.where(assessor_id: assessor_ids).or(
        scope.where(reviewer_id: reviewer_ids),
      )
    end

    private

    def assessor_ids
      Array(params[:assessor_ids])
        .reject(&:blank?)
        .map { |id| id == "null" ? nil : id.to_i }
    end

    def reviewer_ids
      Array(params[:assessor_ids]).reject(&:blank?).reject { |id| id == "null" }
    end
  end
end

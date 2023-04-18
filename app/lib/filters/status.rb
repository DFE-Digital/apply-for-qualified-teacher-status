# frozen_string_literal: true

class Filters::Status < Filters::Base
  def apply
    return scope if statuses.empty?
    scope.where(status: statuses)
  end

  private

  def statuses
    Array(params[:statuses])
      .reject(&:blank?)
      .flat_map do |status|
        if status == "assessment_in_progress"
          %w[initial_assessment assessment_in_progress]
        else
          status
        end
      end
  end
end

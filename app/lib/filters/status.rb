# frozen_string_literal: true

class Filters::Status < Filters::Base
  def apply
    return scope if statuses.empty?

    scope.where(status: statuses)
  end

  private

  def statuses
    Array(params[:statuses]).reject(&:blank?)
  end
end

# frozen_string_literal: true

class Filters::Statuses < Filters::Base
  def apply
    return scope if statuses.empty?

    scope.where("statuses && array[?]::varchar[]", statuses)
  end

  private

  def statuses
    Array(params[:statuses]).compact_blank
  end
end

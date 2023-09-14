# frozen_string_literal: true

class Filters::Stage < Filters::Base
  def apply
    return scope if stage.empty?

    scope.where(stage:)
  end

  private

  def stage
    Array(params[:stage]).compact_blank
  end
end

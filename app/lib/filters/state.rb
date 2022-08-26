# frozen_string_literal: true

class Filters::State < Filters::Base
  def apply
    return scope if states.empty?

    scope.where(state: states)
  end

  private

  def states
    Array(params[:states]).reject(&:blank?)
  end
end

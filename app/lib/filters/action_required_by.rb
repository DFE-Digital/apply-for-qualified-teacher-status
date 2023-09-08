# frozen_string_literal: true

class Filters::ActionRequiredBy < Filters::Base
  def apply
    return scope if action_required_by.empty?

    scope.where(action_required_by:)
  end

  def action_required_by
    Array(params[:action_required_by]).compact_blank
  end
end

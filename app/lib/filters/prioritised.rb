# frozen_string_literal: true

class Filters::Prioritised < Filters::Base
  def apply
    return scope unless prioritised?

    scope.joins(:assessment).where(assessment: { prioritised: true })
  end

  private

  def prioritised?
    ActiveModel::Type::Boolean.new.cast(params[:prioritised])
  end
end

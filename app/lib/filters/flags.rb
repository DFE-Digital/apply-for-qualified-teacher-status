# frozen_string_literal: true

class Filters::Flags < Filters::Base
  def apply
    result = scope

    if prioritised?
      result =
        result.joins(:assessment).where(assessment: { prioritised: true })
    end

    result = result.joins(:active_application_hold) if on_hold?

    result
  end

  private

  def prioritised?
    ActiveModel::Type::Boolean.new.cast(params[:prioritised])
  end

  def on_hold?
    ActiveModel::Type::Boolean.new.cast(params[:on_hold])
  end
end

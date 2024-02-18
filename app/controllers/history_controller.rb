# frozen_string_literal: true

class HistoryController < ApplicationController
  def back
    to_origin = back_params[:origin] == "true"
    method = to_origin ? :pop_to_origin : :pop_back

    path = history_stack.send(method) || default_path
    redirect_to path, status: :see_other
  end

  private

  def default_path
    URI.parse(back_params[:default]).path
  end

  def back_params
    params.permit(:origin, :default)
  end

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end
end

class StaticController < ApplicationController
  layout "two_thirds"

  def current_namespace
    "static"
  end
end

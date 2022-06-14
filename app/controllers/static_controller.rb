class StaticController < ApplicationController
  layout "static_layout"

  def current_namespace
    "static"
  end
end

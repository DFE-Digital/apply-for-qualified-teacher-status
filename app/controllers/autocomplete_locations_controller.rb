# frozen_string_literal: true

class AutocompleteLocationsController < ApplicationController
  LOCATION_AUTOCOMPLETE_GRAPH =
    JSON.parse(File.read("public/location-autocomplete-graph.json"))

  def index
    render json: LOCATION_AUTOCOMPLETE_GRAPH
  end
end

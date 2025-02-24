# frozen_string_literal: true

class AutocompletePassportCountryOfIssuesController < ApplicationController
  AUTOCOMPLETE_GRAPH =
    JSON.parse(
      File.read("public/passport-country-of-issue-autocomplete-graph.json"),
    )

  def index
    render json: AUTOCOMPLETE_GRAPH
  end
end

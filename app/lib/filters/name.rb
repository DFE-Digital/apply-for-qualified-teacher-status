# frozen_string_literal: true

module Filters
  class Name < Base
    def apply
      return scope if name.blank?

      scope.where(
        "CONCAT(given_names, ' ', family_name) ilike ?",
        "%#{name.strip}%",
      )
    end

    private

    def name
      params[:name]
    end
  end
end

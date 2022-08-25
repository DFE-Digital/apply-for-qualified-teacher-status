# frozen_string_literal: true

module Filters
  class Name < Base
    def apply
      return scope if name.blank?

      scope.where("given_names ilike ?", "%#{name}%").or(
        scope.where("family_name ilike ?", "%#{name}%")
      )
    end

    private

    def name
      params[:name]
    end
  end
end

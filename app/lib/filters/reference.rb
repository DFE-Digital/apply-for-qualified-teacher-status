# frozen_string_literal: true

module Filters
  class Reference < Base
    def apply
      if reference.present?
        scope.where("reference ILIKE ?", "%#{reference}%")
      else
        scope
      end
    end

    private

    def reference
      params[:reference]
    end
  end
end

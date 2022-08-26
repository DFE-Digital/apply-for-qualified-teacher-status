# frozen_string_literal: true

module Filters
  class Base
    include FilterPattern

    def initialize(scope:, params:)
      @scope = scope
      @params = params
    end

    def apply
      raise NotImplementedError("apply method must be implemented")
    end

    private

    attr_reader :scope, :params
  end
end

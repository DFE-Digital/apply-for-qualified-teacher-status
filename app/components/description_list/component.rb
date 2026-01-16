# frozen_string_literal: true

module DescriptionList
  class Component < ApplicationComponent
    def initialize(rows:, classes: [])
      super()
      @rows = rows
      @classes = classes
    end

    def classes
      ["app-description-list"] + @classes
    end

    attr_reader :rows
  end
end

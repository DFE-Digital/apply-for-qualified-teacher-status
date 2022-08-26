module ApplicationFormStatusTag
  class Component < ViewComponent::Base
    def initialize(key:, status:)
      super
      @key = key
      @status = status
    end

    def id
      "#{@key}-status"
    end

    def text
      @status.to_s.humanize
    end

    COLOURS = { not_started: "grey", in_progress: "blue" }.freeze

    def colour
      COLOURS[@status]
    end
  end
end

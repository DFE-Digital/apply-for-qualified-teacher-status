module StatusTag
  class Component < ViewComponent::Base
    def initialize(key:, status:, class_context: nil, context: :teacher)
      super
      @key = key
      @status = status.to_sym
      @class_context = class_context
      @context = context
    end

    def id
      "#{@key}-status"
    end

    def text
      status_text(@status, context: @context)
    end

    def classes
      @class_context ? ["#{@class_context}__tag"] : []
    end

    COLOURS = {
      awarded: "green",
      awarded_pending_checks: "turquoise",
      cannot_start: "grey",
      completed: {
        assessor: "green",
      },
      declined: "red",
      draft: "grey",
      expired: "pink",
      in_progress: "blue",
      initial_assessment: "blue",
      invalid: "red",
      not_started: "grey",
      potential_duplicate_in_dqt: "pink",
      received: "purple",
      requested: "yellow",
      submitted: "grey",
      waiting_on: "yellow",
    }.freeze

    def colour
      colours = COLOURS[@status]
      return nil if colours.nil?

      colours.is_a?(String) ? colours : colours[@context]
    end

    delegate :status_text, to: :helpers
  end
end

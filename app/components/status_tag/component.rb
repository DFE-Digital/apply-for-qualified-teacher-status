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
      action_required: "red",
      awarded: "green",
      awarded_pending_checks: "green",
      cannot_start_yet: "grey",
      completed: {
        assessor: "green",
      },
      declined: "red",
      draft: "grey",
      expired: "red",
      further_information_received: "purple",
      further_information_requested: "yellow",
      in_progress: "blue",
      initial_assessment: "blue",
      not_started: "grey",
      potential_duplicate_in_dqt: "red",
      received: "yellow",
      requested: "purple",
      submitted: "grey",
      waiting_on: "purple",
    }.freeze

    def colour
      colours = COLOURS[@status]
      return nil if colours.nil?

      colours.is_a?(String) ? colours : colours[@context]
    end

    delegate :status_text, to: :helpers
  end
end

module StatusTag
  class Component < ViewComponent::Base
    def initialize(key:, status:, class_context: nil)
      super
      @key = key
      @status = status.to_sym
      @class_context = class_context
    end

    def id
      "#{@key}-status"
    end

    def text
      I18n.t(@status, scope: %i[components status_tag])
    end

    def classes
      @class_context ? ["#{@class_context}__tag"] : []
    end

    COLOURS = {
      accepted: "green",
      awarded: "green",
      awarded_pending_checks: "turquoise",
      cannot_start: "grey",
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
      rejected: "red",
      submitted: "grey",
      valid: "green",
      waiting_on: "yellow",
    }.freeze

    def colour
      COLOURS[@status]
    end
  end
end

# frozen_string_literal: true

module StatusTag
  class Component < ViewComponent::Base
    def initialize(status:, id: nil, class_context: nil)
      super
      @status = status.to_sym
      @id = id
      @class_context = class_context
    end

    attr_reader :id

    def text
      I18n.t(@status, scope: %i[components status_tag])
    end

    def classes
      @class_context ? ["#{@class_context}__tag"] : []
    end

    COLOURS = {
      accepted: "green",
      assessment_in_progress: "blue",
      awarded: "green",
      awarded_pending_checks: "turquoise",
      cannot_start: "grey",
      declined: "red",
      draft: "grey",
      expired: "pink",
      in_progress: "blue",
      invalid: "red",
      not_started: "grey",
      overdue: "pink",
      potential_duplicate_in_dqt: "pink",
      preliminary_check: "pink",
      received: "purple",
      rejected: "red",
      requested: "yellow",
      submitted: "grey",
      valid: "green",
      waiting_on: "yellow",
      withdrawn: "red",
    }.freeze

    def colour
      COLOURS[@status]
    end
  end
end

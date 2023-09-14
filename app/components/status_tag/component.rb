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
      assessment: "blue",
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
      overdue_further_information: "pink",
      overdue_professional_standing: "pink",
      overdue_qualification: "pink",
      overdue_reference: "pink",
      potential_duplicate_in_dqt: "pink",
      pre_assessment: "pink",
      preliminary_check: "pink",
      received: "purple",
      received_further_information: "purple",
      received_professional_standing: "purple",
      received_qualification: "purple",
      received_reference: "purple",
      rejected: "red",
      requested: "yellow",
      review: "purple",
      submitted: "grey",
      valid: "green",
      verification: "yellow",
      waiting_on: "yellow",
      waiting_on_further_information: "yellow",
      waiting_on_professional_standing: "yellow",
      waiting_on_qualification: "yellow",
      waiting_on_reference: "yellow",
      withdrawn: "red",
    }.freeze

    def colour
      COLOURS[@status]
    end
  end
end

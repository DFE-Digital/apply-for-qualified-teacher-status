# frozen_string_literal: true

module StatusTag
  class Component < ViewComponent::Base
    def initialize(statuses, id: nil, class_context: nil)
      super
      @statuses = statuses
      @id = id
      @class_context = class_context
    end

    attr_reader :statuses, :id, :class_context

    def tags
      Array(statuses).map do |status|
        {
          text: I18n.t(status, scope: %i[components status_tag]),
          colour: COLOURS[status.to_sym],
          classes: class_context ? ["#{class_context}__tag"] : [],
          html_attributes: id ? { id: } : {},
        }
      end
    end

    COLOURS = {
      accepted: "green",
      assessment: "blue",
      assessment_in_progress: "blue",
      assessment_not_started: "grey",
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
      overdue_lops: "pink",
      overdue_professional_standing: "pink",
      overdue_qualification: "pink",
      overdue_reference: "pink",
      potential_duplicate_in_dqt: "pink",
      pre_assessment: "pink",
      preliminary_check: "pink",
      received: "purple",
      received_further_information: "purple",
      received_lops: "purple",
      received_professional_standing: "purple",
      received_qualification: "purple",
      received_reference: "purple",
      rejected: "red",
      requested: "yellow",
      review: "purple",
      submitted: "grey",
      valid: "green",
      verification: "yellow",
      verification_in_progress: "blue",
      verification_not_started: "grey",
      waiting_on: "yellow",
      waiting_on_further_information: "yellow",
      waiting_on_lops: "yellow",
      waiting_on_professional_standing: "yellow",
      waiting_on_qualification: "yellow",
      waiting_on_reference: "yellow",
      withdrawn: "red",
    }.freeze
  end
end

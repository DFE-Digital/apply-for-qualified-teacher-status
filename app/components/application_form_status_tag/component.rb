module ApplicationFormStatusTag
  class Component < ViewComponent::Base
    attr_reader :class_context

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
      I18n.t("application_form.status.#{@status}")
    end

    def classes
      class_context ? ["#{class_context}__tag"] : []
    end

    COLOURS = {
      action_required: "red",
      not_started: "grey",
      in_progress: "blue",
      initial_assessment: "blue",
      further_information_requested: "yellow",
      further_information_received: "purple",
      awarded: "green",
      declined: "red",
      draft: "grey",
      submitted: "grey",
      cannot_start_yet: "grey",
      completed: "green",
    }.freeze

    def colour
      COLOURS[@status]
    end
  end
end

module ApplicationFormStatusTag
  class Component < ViewComponent::Base
    attr_reader :class_context

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
      key_with_context = "application_form.status.#{@status}.#{@context}"
      key_without_context = "application_form.status.#{@status}"
      I18n.t(key_with_context, default: I18n.t(key_without_context))
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
      completed: {
        assessor: "green",
        teacher: "blue",
      },
    }.freeze

    def colour
      colours = COLOURS[@status]
      colours.is_a?(String) ? colours : colours.fetch(@context)
    end
  end
end

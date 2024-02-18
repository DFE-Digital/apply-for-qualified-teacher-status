# frozen_string_literal: true

module HistoryTrackable
  extend ActiveSupport::Concern

  included do
    before_action :track_history, if: -> { request.get? }

    cattr_accessor :history_origin_actions,
                   :history_check_actions,
                   :history_reset_actions
  end

  class_methods do
    def define_history_origin(*actions)
      self.history_origin_actions = actions.map(&:to_s)
    end

    def define_history_check(*actions, identifier: true)
      self.history_check_actions ||= {}
      actions.each { |action| history_check_actions[action.to_s] = identifier }
    end

    def define_history_reset(*actions)
      self.history_reset_actions = actions.map(&:to_s)
    end
  end

  private

  def track_history
    origin = (history_origin_actions || []).include?(action_name)

    check_identifier = (history_check_actions || {}).fetch(action_name, false)
    check =
      check_identifier.is_a?(Symbol) ? send(check_identifier) : check_identifier

    reset = (history_reset_actions || []).include?(action_name)

    history_stack.push_self(request, origin:, check:, reset:)
  end

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end
end

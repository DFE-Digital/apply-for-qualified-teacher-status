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
    def define_history_origins(*actions)
      self.history_origin_actions = actions.map(&:to_s)
    end

    def define_history_checks(*actions)
      self.history_check_actions = actions.map(&:to_s)
    end

    def define_history_resets(*actions)
      self.history_reset_actions = actions.map(&:to_s)
    end
  end

  private

  def track_history
    origin = (history_origin_actions || []).include?(action_name)
    check = (history_check_actions || []).include?(action_name)
    reset = (history_reset_actions || []).include?(action_name)
    history_stack.push_self(request, origin:, check:, reset:)
  end

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end
end

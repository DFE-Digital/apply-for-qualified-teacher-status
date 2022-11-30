# frozen_string_literal: true

module HistoryTrackable
  extend ActiveSupport::Concern

  included { before_action :push_self, if: -> { request.get? } }

  def push_self
    history_stack.push_self(request, origin: false, check: false)
  end

  def push_self_as_origin
    history_stack.push_self(request, origin: true, check: false)
  end

  def push_self_as_origin_and_reset
    history_stack.push_self(request, origin: true, check: false, reset: true)
  end

  def push_self_as_check
    history_stack.push_self(request, origin: false, check: true)
  end

  private

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end
end

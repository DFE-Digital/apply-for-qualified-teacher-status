# frozen_string_literal: true

class HistoryStack
  def initialize(session:)
    @session = session
  end

  def push_self(request, origin:, reset: false)
    push(path: request.fullpath, origin:, reset:)
  end

  def replace_self(path:, origin:)
    pop
    push(path:, origin:, reset: false)
  end

  def pop_back
    pop # self

    entry = pop
    entry[:path] if entry
  end

  def pop_to_origin
    pop # self

    loop do
      entry = pop
      return nil if entry.nil?
      return entry[:path] if entry[:origin]
    end
  end

  private

  def push(path:, origin:, reset:)
    update_stack do |stack|
      stack.clear if reset
      current_entry = stack.last
      new_entry = { path:, origin: }
      stack.push(new_entry) if current_entry != new_entry
    end
  end

  def pop
    update_stack(&:pop)
  end

  def update_stack
    stack = session[:history_stack] || []
    return_value = yield stack
    session[:history_stack] = stack
    return_value
  end

  attr_reader :session
end

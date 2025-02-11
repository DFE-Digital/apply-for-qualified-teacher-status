# frozen_string_literal: true

class HistoryStack
  def initialize(session:)
    @session = session
  end

  def push(path:, origin:, check:, reset:)
    apply_to_stack do |stack|
      stack.clear if reset
      current_entry = stack.last
      new_entry = { path:, origin:, check: }
      stack.push(new_entry) if current_entry != new_entry
    end
  end

  def push_self(request, origin:, check:, reset: false)
    push(path: request.fullpath, origin:, check:, reset:)
  end

  def pop
    apply_to_stack(&:pop)
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

  def replace_self(path:, origin:, check:)
    pop
    push(path:, origin:, check:, reset: false)
  end

  def last_entry
    apply_to_stack(&:second_to_last)
  end

  def last_entry_is_check?(identifier: nil)
    entry = last_entry
    return false unless entry

    if identifier.present?
      [true, identifier].include?(entry[:check])
    else
      entry[:check].present?
    end
  end

  def last_path_if_check(identifier: nil)
    last_entry[:path] if last_entry_is_check?(identifier:)
  end

  private

  def apply_to_stack
    stack = session[:history_stack] || []
    return_value = yield stack
    session[:history_stack] = stack
    return_value
  end

  attr_reader :session
end

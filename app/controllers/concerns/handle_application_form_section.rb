# frozen_string_literal: true

module HandleApplicationFormSection
  extend ActiveSupport::Concern

  def handle_application_form_section(
    form:,
    check_identifier: nil,
    if_success_then_redirect: %i[teacher_interface application_form],
    if_failure_then_render: :edit
  )
    save_and_continue = params[:button] != "save_and_return"

    if form.save(validate: save_and_continue)
      check_path = check_path_if_previous(check_identifier)

      if save_and_continue
        redirect_to if_success_then_redirect.try(:call, check_path) ||
                      check_path || if_success_then_redirect
      else
        redirect_to check_path || %i[teacher_interface application_form]
      end
    else
      render if_failure_then_render, status: :unprocessable_entity
    end
  end

  private

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end

  def check_path_if_previous(check_identifier)
    entry = history_stack.last_entry
    return nil unless entry

    return nil unless entry[:check]

    is_check =
      if check_identifier.present?
        entry[:check] == true || entry[:check] == check_identifier
      else
        entry[:check].present?
      end

    entry[:path] if is_check
  end
end

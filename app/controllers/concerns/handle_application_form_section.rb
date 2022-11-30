# frozen_string_literal: true

module HandleApplicationFormSection
  extend ActiveSupport::Concern

  def handle_application_form_section(
    form:,
    if_success_then_redirect: %i[teacher_interface application_form],
    if_failure_then_render: :edit
  )
    save_and_continue = params[:button] == "save_and_continue"

    if form.save(validate: save_and_continue)
      if save_and_continue
        redirect_to if_success_then_redirect.try(
                      :call,
                      check_path_if_previous,
                    ) || check_path_if_previous || if_success_then_redirect
      else
        redirect_to check_path_if_previous ||
                      %i[teacher_interface application_form]
      end
    else
      render if_failure_then_render, status: :unprocessable_entity
    end
  end

  private

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end

  def check_path_if_previous
    entry = history_stack.last_entry
    entry[:path] if entry && entry[:check]
  end
end

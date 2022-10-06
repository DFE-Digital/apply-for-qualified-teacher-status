# frozen_string_literal: true

module HandleApplicationFormSection
  extend ActiveSupport::Concern

  def handle_application_form_section(
    form:,
    if_success_then_redirect:,
    if_failure_then_render:
  )
    save_and_continue = params[:next] == "save_and_continue"

    if form.save(validate: save_and_continue)
      if save_and_continue
        redirect_to if_success_then_redirect.try(:call) ||
                      if_success_then_redirect
      else
        redirect_to %i[teacher_interface application_form]
      end
    else
      render if_failure_then_render, status: :unprocessable_entity
    end
  end
end

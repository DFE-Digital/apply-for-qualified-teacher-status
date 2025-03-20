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
      check_path =
        history_stack.last_path_if_check(identifier: check_identifier)

      if save_and_continue
        redirect_to if_success_then_redirect.try(:call, check_path) ||
                      check_path || if_success_then_redirect
      else
        redirect_to check_path || %i[teacher_interface application_form]
      end
    else
      send_errors_to_big_query(form)

      render if_failure_then_render, status: :unprocessable_entity
    end
  end

  private

  def history_stack
    @history_stack ||= HistoryStack.new(session:)
  end

  def send_errors_to_big_query(form)
    error_events = []

    form.errors.each do |error|
      error_events << DfE::Analytics::Event
        .new
        .with_type(:form_validation_failure)
        .with_user(current_teacher)
        .with_request_details(request)
        .with_data(
          data: {
            form_class: form.class.to_s,
            error_attribute: error.attribute,
            error_message: error.message,
          },
        )
    end

    DfE::Analytics::SendEvents.do(error_events) if error_events.present?
  end
end

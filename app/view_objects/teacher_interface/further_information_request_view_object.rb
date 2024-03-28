# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestViewObject
    def initialize(current_teacher:, params:)
      @current_teacher = current_teacher
      @params = params
    end

    def further_information_request
      @further_information_request ||=
        FurtherInformationRequest
          .joins(:assessment)
          .where(received_at: nil, assessments: { application_form: })
          .find(params[:id])
    end

    def task_list_items
      further_information_request
        .items
        .order(:created_at)
        .map do |item|
          {
            title: item_name(item),
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              item,
            ],
            status: item.state,
          }
        end
    end

    def can_check_answers?
      further_information_request.items.all?(&:completed?)
    end

    alias_method :can_submit?, :can_check_answers?

    def check_your_answers_fields
      further_information_request
        .items
        .order(:created_at)
        .each_with_object({}) do |item, memo|
          memo[item.id] = {
            title: item_name(item),
            value: item_value(item),
            href: [
              :edit,
              :teacher_interface,
              :application_form,
              further_information_request,
              item,
            ],
          }
        end
    end

    private

    attr_reader :current_teacher, :params

    def item_value(item)
      if item.text?
        item.response
      elsif item.document?
        item.document
      elsif item.work_history_contact?
        "Contact name: #{item.contact_name}<br/>
         Contact job: #{item.contact_job}<br/>
         Contact email: #{item.contact_email}".html_safe
      end
    end
    def application_form
      @application_form ||= current_teacher.application_form
    end

    def item_name(item)
      case item.information_type
      when "text"
        I18n.t(
          "teacher_interface.further_information_request.show.failure_reason.#{item.failure_reason_key}",
        )
      when "work_history_contact"
        "Add work history details"
      when "document"
        "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")} document"
      end
    end
  end
end

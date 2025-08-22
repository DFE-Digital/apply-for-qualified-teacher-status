# frozen_string_literal: true

module TeacherInterface
  class FurtherInformationRequestItemViewObject
    def initialize(current_teacher:, params:)
      @current_teacher = current_teacher
      @params = params
    end

    def further_information_request_item
      @further_information_request_item ||=
        FurtherInformationRequestItem
          .joins(further_information_request: :assessment)
          .where(
            further_information_request: {
              received_at: nil,
              assessments: {
                application_form:,
              },
            },
          )
          .find(params[:id])
    end

    def item_name
      case further_information_request_item.information_type
      when "text"
        I18n.t(
          further_information_request_item.failure_reason_key,
          scope: %i[
            teacher_interface
            further_information_request
            show
            failure_reason
          ],
        )
      when "work_history_contact"
        "Update reference details for #{further_information_request_item.work_history.school_name}"
      when "document"
        if further_information_request_item.document.document_type == "passport"
          "Upload your #{I18n.t("document.document_type.#{further_information_request_item.document.document_type}")}"
        else
          "Upload your " \
            "#{I18n.t("document.document_type.#{further_information_request_item.document.document_type}")} document"
        end
      end
    end

    def item_description
      I18n.t(
        further_information_request_item.failure_reason_key,
        scope: %i[
          teacher_interface
          application_forms
          show
          declined
          failure_reasons
        ],
      ).gsub(".", "")
    end

    def application_form
      @application_form ||= current_teacher.application_form
    end

    private

    attr_reader :current_teacher, :params
  end
end

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

    def grouped_task_list_items
      grouped_items =
        items_by_assessment_section.map do |assessment_section, items|
          {
            heading:
              I18n.t(
                assessment_section.key,
                scope: %i[
                  teacher_interface
                  further_information_request
                  show
                  section
                ],
              ),
            items: task_list_items(items),
          }
        end

      grouped_items << {
        heading:
          I18n.t(
            :check_your_answers,
            scope: %i[
              teacher_interface
              further_information_request
              show
              section
            ],
          ),
        items: [
          {
            title:
              I18n.t(
                "teacher_interface.further_information_request.show.check",
              ),
            href:
              if can_check_answers?
                [
                  :edit,
                  :teacher_interface,
                  :application_form,
                  further_information_request,
                ]
              end,
            status: can_check_answers? ? "not_started" : "cannot_start",
          },
        ],
      }

      grouped_items
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

    def application_form
      @application_form ||= current_teacher.application_form
    end

    private

    attr_reader :current_teacher, :params

    def items_by_assessment_section
      @items_by_assessment_section ||=
        FurtherInformationRequestItemsByAssessmentSection.call(
          further_information_request:,
        )
    end

    def task_list_items(items)
      items.map do |item|
        {
          title: item_name(item),
          description: item_description(item),
          href: [
            :edit,
            :teacher_interface,
            :application_form,
            further_information_request,
            item,
          ],
          status: item.status,
        }
      end
    end

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

    def item_name(item)
      case item.information_type
      when "text"
        I18n.t(
          "teacher_interface.further_information_request.show.failure_reason.#{item.failure_reason_key}",
        )
      when "work_history_contact"
        "Update reference details for #{item.work_history.school_name}"
      when "document"
        if item.document.document_type == "passport"
          "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")}"
        else
          "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")} document"
        end
      end
    end

    def item_description(item)
      I18n.t(
        item.failure_reason_key,
        scope: %i[
          teacher_interface
          application_forms
          show
          declined
          failure_reasons
        ],
      ).gsub(".", "")
    end
  end
end

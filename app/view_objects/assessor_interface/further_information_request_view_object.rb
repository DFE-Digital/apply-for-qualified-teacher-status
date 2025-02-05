# frozen_string_literal: true

class AssessorInterface::FurtherInformationRequestViewObject
  def initialize(params:)
    @params = params
  end

  def further_information_request
    @further_information_request ||=
      FurtherInformationRequest
        .joins(assessment: :application_form)
        .received
        .where(
          assessment_id: params[:assessment_id],
          application_form: {
            reference: params[:application_form_reference],
          },
        )
        .find(params[:id])
  end

  delegate :application_form, :assessment, to: :further_information_request

  def review_items
    further_information_request
      .items
      .order(:created_at)
      .map do |item|
        {
          heading:
            I18n.t(
              item.failure_reason_key,
              scope: %i[
                assessor_interface
                assessment_sections
                failure_reasons
                as_statement
              ],
            ),
          description: item.failure_reason_assessor_feedback,
          check_your_answers: {
            id: "further-information-requested-#{item.id}",
            model: item,
            title:
              I18n.t(
                "assessor_interface.further_information_requests.edit.check_your_answers",
              ),
            fields: review_items_fields(item),
          },
          work_history_summary_list_rows:
            if item.work_history_contact?
              [
                {
                  key: {
                    text: "Contact name",
                  },
                  value: {
                    text: item.work_history.contact_name,
                  },
                },
                {
                  key: {
                    text: "Contact job",
                  },
                  value: {
                    text: item.work_history.contact_job,
                  },
                },
                {
                  key: {
                    text: "Contact email",
                  },
                  value: {
                    text: item.work_history.contact_email,
                  },
                },
              ]
            end,
        }.compact
      end
  end

  def can_update?
    further_information_request.review_passed.nil? ||
      assessment.request_further_information?
  end

  private

  attr_reader :params

  def item_text(item)
    case item.information_type
    when "text"
      I18n.t(
        "teacher_interface.further_information_request.show.failure_reason.#{item.failure_reason_key}",
      )
    when "document"
      if item.document.document_type == "passport"
        "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")}"
      else
        "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")} document"
      end
    when "work_history_contact"
      "Please provide new contact information for your work history contact"
    end
  end

  def review_items_fields(item)
    if item.work_history_contact?
      {
        contact_name: {
          title: "Contact name",
          value: item.contact_name,
        },
        contact_job: {
          title: "Contact job",
          value: item.contact_job,
        },
        contact_email: {
          title: "Contact email",
          value: item.contact_email,
        },
      }
    else
      {
        item.id => {
          title: item_text(item),
          value: item.text? ? item.response : item.document,
        },
      }
    end
  end
end

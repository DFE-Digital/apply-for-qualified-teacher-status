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
          assessment: {
            application_form_id: params[:application_form_id],
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
            fields: {
              item.id => {
                title: item_text(item),
                value: item.text? ? item.response : item.document,
              },
            },
          },
        }
      end
  end

  def can_update?
    further_information_request.passed.nil? ||
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
      "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")} document"
    end
  end
end

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

  def application_form
    further_information_request.assessment.application_form
  end

  def check_your_answers_fields
    further_information_request
      .items
      .order(:created_at)
      .each_with_object({}) do |item, memo|
        memo[item.id] = {
          title: item_text(item),
          value: item.text? ? item.response : item.document,
        }
      end
  end

  private

  attr_reader :params

  def item_text(item)
    case item.information_type
    when "text"
      I18n.t(
        "teacher_interface.further_information_request.show.failure_reason.#{item.failure_reason}",
      )
    when "document"
      "Upload your #{I18n.t("document.document_type.#{item.document.document_type}")} document"
    end
  end
end

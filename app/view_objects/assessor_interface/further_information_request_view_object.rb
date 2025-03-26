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
          id: "further-information-requested-#{item.id}",
          recieved_date: further_information_request.received_at.to_date.to_fs,
          requested_date:
            further_information_request.requested_at.to_date.to_fs,
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
          assessor_request: item.failure_reason_assessor_feedback,
          applicant_text_response: item.response,
          applicant_contact_response: work_history_contact_response(item),
          applicant_upload_response: item.document,
        }.compact
      end
  end

  def can_update?
    further_information_request.review_passed.nil? ||
      assessment.request_further_information?
  end

  private

  attr_reader :params

  def work_history_contact_response(item)
    return unless item.work_history_contact?

    {
      contact_name: {
        title: "Contact’s name",
        value: item.contact_name,
      },
      contact_job: {
        title: "Contact’s job",
        value: item.contact_job,
      },
      contact_email: {
        title: "Contact’s email",
        value: item.contact_email,
      },
    }.map { |_key, value| "#{value[:title]}: #{value[:value]}" }
  end
end

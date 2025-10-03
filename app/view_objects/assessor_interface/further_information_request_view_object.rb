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

  def title
    key =
      if further_information_request.first_request?
        "first_request"
      elsif further_information_request.second_request?
        "second_request"
      else
        "last_request"
      end

    I18n.t("assessor_interface.further_information_requests.edit.title.#{key}")
  end

  def grouped_review_items_by_assessment_section
    items_by_assessment_section.map do |assessment_section, items|
      {
        section_id: assessment_section.id,
        heading:
          I18n.t(
            assessment_section.key,
            scope: %i[
              assessor_interface
              further_information_requests
              edit
              assessment_section
            ],
          ),
        section_link_text:
          I18n.t(
            assessment_section.key,
            scope: %i[
              assessor_interface
              further_information_requests
              edit
              assessment_section_links
            ],
          ),
        review_items: review_items(items),
      }
    end
  end

  def grouped_follow_up_items_by_assessment_section
    grouped_items =
      items_by_assessment_section.map do |assessment_section, items|
        items_requiring_follow_up =
          items.select(&:review_decision_further_information?)

        next if items_requiring_follow_up.empty?

        {
          section_id: assessment_section.id,
          heading:
            I18n.t(
              assessment_section.key,
              scope: %i[
                assessor_interface
                further_information_requests
                edit
                assessment_section
              ],
            ),
          review_items: review_items(items_requiring_follow_up),
        }
      end

    grouped_items.compact
  end

  def review_items(items)
    items
      .sort_by(&:failure_reason_key)
      .map do |item|
        {
          id: item.id,
          recieved_date: further_information_request.received_at.to_date.to_fs,
          requested_date:
            further_information_request.requested_at.to_date.to_fs,
          heading: item_heading(item),
          assessor_request: item.failure_reason_assessor_feedback,
          applicant_text_response: item.response,
          applicant_contact_response: work_history_contact_response(item),
          contact_email_domain_has_eligibility_concern:
            work_history_contact_email_domain_has_eligibility_concern?(item),
          applicant_upload_response: item.document,
          review_decision_note: item.review_decision_note,
        }.compact
      end
  end

  def can_update?
    further_information_request.review_passed.nil? ||
      (
        assessment.request_further_information? &&
          assessment.latest_further_information_request ==
            further_information_request
      )
  end

  def can_decline?
    can_update? &&
      further_information_request.items.any?(&:review_decision_decline?)
  end

  def can_follow_up?
    can_update? &&
      further_information_request.items.any?(
        &:review_decision_further_information?
      ) && further_information_request.items.none?(&:review_decision_decline?)
  end

  private

  attr_reader :params

  def items_by_assessment_section
    @items_by_assessment_section ||=
      FurtherInformationRequestItemsByAssessmentSection.call(
        further_information_request:,
      )
  end

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

  def work_history_contact_email_domain_has_eligibility_concern?(item)
    return unless item.work_history_contact?

    domain = EmailAddress.new(item.contact_email).host_name

    EligibilityDomain.exists?(domain:, archived_at: nil)
  end

  def item_heading(item)
    content =
      I18n.t(
        item.failure_reason_key,
        scope: %i[
          assessor_interface
          assessment_sections
          failure_reasons
          as_statement
        ],
      )

    if item.work_history_contact?
      content.gsub(".", " for #{item.work_history.school_name}.")
    else
      content
    end
  end
end

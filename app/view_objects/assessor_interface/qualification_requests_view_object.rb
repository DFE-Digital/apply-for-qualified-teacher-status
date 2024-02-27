# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsViewObject
    include QualificationHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def all_task_items
      items = [
        check_consent_method_task_item,
        if generate_consent_document_in_all_qualifications?
          generate_consent_document_task_item
        end,
        if send_consent_document_in_all_qualifications?
          send_consent_document_task_item
        end,
      ].compact

      if show_individual_task_items?
        items
      else
        items +
          individual_task_items_for(
            qualification_request: qualification_requests.first,
          )
      end
    end

    def show_individual_task_items?
      all_consent_methods_selected? && qualification_requests.count > 1
    end

    def qualification_requests
      @qualification_requests ||=
        application_form.assessment.qualification_requests.order_by_role
    end

    def consent_requests
      @consent_requests ||=
        application_form.assessment.consent_requests.order_by_role
    end

    def individual_task_items_for(qualification_request:)
      return [] if qualification_request.consent_method_unknown?

      if qualification_request.consent_method_unsigned?
        unsigned_consent_method_task_items(qualification_request)
      else
        signed_consent_method_task_items(qualification_request)
      end + ecctis_task_items(qualification_request)
    end

    private

    attr_reader :application_form

    delegate :assessment, to: :application_form

    def all_consent_methods_selected?
      qualification_requests.none?(&:consent_method_unknown?)
    end

    def check_consent_method_task_item
      status =
        if qualification_requests.all?(&:consent_method_unknown?)
          "not_started"
        elsif all_consent_methods_selected?
          "completed"
        else
          "in_progress"
        end

      { name: "Check and select consent method", link: "#", status: }
    end

    def generate_consent_document_in_all_qualifications?
      all_consent_methods_selected? &&
        qualification_requests.consent_method_unsigned.count >= 2
    end

    def generate_consent_document_task_item
      {
        name: "Generate consent document",
        link: [
          :consent_letter,
          :assessor_interface,
          application_form,
          assessment,
          :qualification_requests,
        ],
        status:
          (
            if assessment.unsigned_consent_document_generated
              "completed"
            else
              "not_started"
            end
          ),
      }
    end

    def unsigned_consent_method_task_items(_qualification_request)
      if generate_consent_document_in_all_qualifications?
        []
      else
        [generate_consent_document_task_item]
      end
    end

    def send_consent_document_in_all_qualifications?
      all_consent_methods_selected? && consent_requests.count >= 2
    end

    def send_consent_document_task_item
      {
        name: "Send consent document to applicant",
        link: "#",
        status:
          if consent_requests.map(&:unsigned_consent_document).all?(
               &:completed?
             )
            consent_requests.all?(&:requested?) ? "completed" : "not_started"
          else
            "cannot_start"
          end,
      }
    end

    def signed_consent_method_task_items(qualification_request)
      consent_request =
        consent_requests.find_by!(
          qualification: qualification_request.qualification,
        )

      [
        {
          name: "Upload consent document",
          link: "#",
          status:
            (
              if consent_request.unsigned_consent_document.completed?
                "completed"
              else
                "not_started"
              end
            ),
        },
        unless send_consent_document_in_all_qualifications?
          send_consent_document_task_item
        end,
        {
          name: "Record applicant response",
          link: "#",
          status: consent_request.status(not_requested: "cannot_start"),
        },
      ]
    end

    def ecctis_task_items(qualification_request)
      can_start =
        (
          qualification_request.consent_method_unsigned? &&
            assessment.unsigned_consent_document_generated
        ) ||
          consent_requests.verified.exists?(
            qualification: qualification_request.qualification,
          )

      [
        {
          name: "Request Ecctis verification",
          link: "#",
          status:
            if can_start
              qualification_request.requested? ? "completed" : "not_started"
            else
              "cannot_start"
            end,
        },
        {
          name: "Record Ecctis response",
          link: "#",
          status:
            if can_start && qualification_request.requested?
              qualification_request.received? ? "completed" : "not_started"
            else
              "cannot_start"
            end,
        },
      ]
    end
  end
end

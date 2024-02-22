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

    def all_consent_methods_selected?
      qualification_requests.none?(&:consent_method_unknown?)
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
      consent_task_items(qualification_request) +
        ecctis_task_items(qualification_request)
    end

    private

    attr_reader :application_form

    delegate :assessment, to: :application_form

    def check_consent_method_task_item
      cannot_change =
        assessment.unsigned_consent_document_generated ||
          consent_requests.exists? || qualification_requests.requested.exists?

      {
        name: "Check and select consent method",
        link:
          unless cannot_change
            [
              (
                if all_consent_methods_selected?
                  :check_consent_methods
                else
                  :consent_methods
                end
              ),
              :assessor_interface,
              application_form,
              assessment,
              :qualification_requests,
            ]
          end,
        status:
          if all_consent_methods_selected?
            "completed"
          elsif qualification_requests.all?(&:consent_method_unknown?)
            "not_started"
          else
            "in_progress"
          end,
      }
    end

    def generate_consent_document_in_all_qualifications?
      all_consent_methods_selected? &&
        qualification_requests.consent_method_unsigned.count >= 2
    end

    def generate_consent_document_task_item
      {
        name: "Generate consent document",
        link: [
          :unsigned_consent_document,
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

    def send_consent_document_in_all_qualifications?
      all_consent_methods_selected? &&
        qualification_requests.consent_method_signed.count >= 2
    end

    def send_consent_document_task_item
      all_documents_completed =
        qualification_requests.consent_method_signed.count ==
          consent_requests.count &&
          consent_requests
            .map(&:unsigned_consent_document)
            .all? { |document| document.completed? && document.downloadable? }

      all_consents_requested = consent_requests.all?(&:requested?)

      {
        name:
          "Send consent #{"document".pluralize(consent_requests.count)} to applicant",
        link:
          if all_documents_completed && !all_consents_requested
            [
              :request,
              :assessor_interface,
              application_form,
              assessment,
              :consent_requests,
            ]
          end,
        status:
          if all_documents_completed
            all_consents_requested ? "completed" : "not_started"
          else
            "cannot_start"
          end,
      }
    end

    def signed_consent_method_task_items(qualification_request)
      consent_request =
        consent_requests.find_by(
          qualification: qualification_request.qualification,
        )

      [
        {
          name: "Upload consent document",
          link:
            if consent_request.nil?
              Rails
                .application
                .routes
                .url_helpers
                .new_assessor_interface_application_form_assessment_consent_request_path(
                application_form,
                assessment,
                qualification_id: qualification_request.qualification.id,
              )
            elsif !consent_request.requested?
              [
                :check_upload,
                :assessor_interface,
                application_form,
                assessment,
                consent_request,
              ]
            end,
          status:
            (
              if consent_request&.unsigned_consent_document&.completed?
                if consent_request&.unsigned_consent_document&.downloadable?
                  "completed"
                else
                  "in_progress"
                end
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
          status:
            consent_request&.status(not_requested: "cannot_start") ||
              "cannot_start",
        },
      ]
    end

    def consent_task_items(qualification_request)
      if qualification_request.consent_method_unsigned? &&
           !generate_consent_document_in_all_qualifications?
        [generate_consent_document_task_item]
      elsif qualification_request.consent_method_signed?
        signed_consent_method_task_items(qualification_request)
      else
        []
      end
    end

    def ecctis_task_items(qualification_request)
      if qualification_request.consent_method_unknown? &&
           !qualification_request.requested?
        return []
      end

      can_start =
        qualification_request.consent_method_none? ||
          (
            qualification_request.consent_method_unsigned? &&
              assessment.unsigned_consent_document_generated
          ) ||
          (
            qualification_request.consent_method_signed? &&
              consent_requests.verified.exists?(
                qualification: qualification_request.qualification,
              )
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
            if qualification_request.requested?
              qualification_request.received? ? "completed" : "not_started"
            else
              "cannot_start"
            end,
        },
      ]
    end
  end
end

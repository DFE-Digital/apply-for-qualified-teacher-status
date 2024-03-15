# frozen_string_literal: true

module TeacherInterface
  class ConsentRequestsViewObject
    include QualificationHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def task_list_sections
      consent_requests.map do |consent_request|
        {
          title: qualification_title(consent_request.qualification),
          items: task_list_items(consent_request),
        }
      end
    end

    def can_submit?
      consent_requests.all? do |consent_request|
        consent_request.unsigned_document_downloaded &&
          consent_request.signed_consent_document.completed?
      end
    end

    def check_your_answers_fields
      consent_requests.each_with_object({}) do |consent_request, memo|
        memo[consent_request.id] = {
          title: qualification_title(consent_request.qualification),
          value: consent_request.signed_consent_document,
          href: [
            :teacher_interface,
            :application_form,
            consent_request.signed_consent_document,
          ],
        }
      end
    end

    private

    attr_reader :application_form

    def consent_requests
      @consent_requests ||=
        application_form.assessment.consent_requests.requested.order_by_user
    end

    def task_list_items(consent_request)
      institution_name = consent_request.qualification.institution_name

      [
        {
          link: [
            :download,
            :teacher_interface,
            :application_form,
            consent_request,
          ],
          name: "Download #{institution_name} consent document",
          status: download_unsigned_consent_document_status(consent_request),
        },
        {
          link: [
            :teacher_interface,
            :application_form,
            consent_request.signed_consent_document,
          ],
          name: "Upload #{institution_name} consent document",
          status: upload_signed_consent_document_status(consent_request),
        },
      ]
    end

    def download_unsigned_consent_document_status(consent_request)
      consent_request.unsigned_document_downloaded ? :completed : :not_started
    end

    def upload_signed_consent_document_status(consent_request)
      if consent_request.unsigned_document_downloaded
        if consent_request.signed_consent_document.completed?
          :completed
        else
          :not_started
        end
      else
        :cannot_start
      end
    end
  end
end

# frozen_string_literal: true

module TeacherInterface
  class QualificationRequestsViewObject
    include QualificationHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def task_list_sections
      qualification_requests.map do |qualification_request|
        {
          title: qualification_title(qualification_request.qualification),
          items: task_list_items(qualification_request),
        }
      end
    end

    def can_submit?
      qualification_requests.all? do |qualification_request|
        qualification_request.unsigned_consent_document_downloaded &&
          qualification_request.signed_consent_document.completed?
      end
    end

    def check_your_answers_fields
      qualification_requests.each_with_object(
        {},
      ) do |qualification_request, memo|
        memo[qualification_request.id] = {
          title: qualification_title(qualification_request.qualification),
          value: qualification_request.signed_consent_document,
          href: [
            :teacher_interface,
            :application_form,
            qualification_request.signed_consent_document,
          ],
        }
      end
    end

    private

    attr_reader :application_form

    def qualification_requests
      @qualification_requests ||=
        application_form
          .assessment
          .qualification_requests
          .order_by_user
          .consent_respondable
    end

    def task_list_items(qualification_request)
      institution_name = qualification_request.qualification.institution_name

      [
        {
          link: [
            :download,
            :teacher_interface,
            :application_form,
            qualification_request,
          ],
          name: "Download #{institution_name} consent document",
          status:
            download_unsigned_consent_document_status(qualification_request),
        },
        {
          link: [
            :teacher_interface,
            :application_form,
            qualification_request.signed_consent_document,
          ],
          name: "Upload #{institution_name} consent document",
          status: upload_signed_consent_document_status(qualification_request),
        },
      ]
    end

    def download_unsigned_consent_document_status(qualification_request)
      if qualification_request.unsigned_consent_document_downloaded
        :completed
      else
        :not_started
      end
    end

    def upload_signed_consent_document_status(qualification_request)
      if qualification_request.unsigned_consent_document_downloaded
        if qualification_request.signed_consent_document.completed?
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

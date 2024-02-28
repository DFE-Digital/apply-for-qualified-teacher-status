# frozen_string_literal: true

module AssessorInterface
  class QualificationRequestsController < BaseController
    include HistoryTrackable

    before_action :set_collection_variables,
                  only: %i[
                    index
                    index_consent_methods
                    check_consent_methods
                    edit_unsigned_consent_document
                    update_unsigned_consent_document
                    generate_unsigned_consent_document
                  ]
    before_action :set_member_variables,
                  only: %i[
                    edit
                    update
                    edit_consent_method
                    update_consent_method
                    edit_request
                    update_request
                    edit_review
                    update_review
                  ]

    skip_before_action :track_history, only: :generate_unsigned_consent_document
    define_history_origin :index
    define_history_check :check_consent_methods

    def index
      @view_object =
        AssessorInterface::QualificationRequestsViewObject.new(
          application_form:,
        )

      render layout: "full_from_desktop"
    end

    def index_consent_methods
    end

    def check_consent_methods
    end

    def edit_unsigned_consent_document
      @form =
        GenerateUnsignedConsentDocumentForm.new(
          assessment:,
          generated: assessment.unsigned_consent_document_generated,
        )
    end

    def update_unsigned_consent_document
      @form =
        GenerateUnsignedConsentDocumentForm.new(
          generate_unsigned_consent_document_form_params.merge(assessment:),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :qualification_requests,
                    ]
      else
        render :edit_unsigned_consent_document, status: :unprocessable_entity
      end
    end

    def generate_unsigned_consent_document
      send_data(
        ConsentLetter.new(application_form:).render_pdf,
        filename: "Apply for QTS - Consent Letter.pdf",
        type: "application/pdf",
        disposition: "inline",
      )
    end

    def edit
      received =
        if requestable.received?
          true
        elsif requestable.expired?
          false
        end

      passed = (requestable.review_passed if requestable.received?)

      failed =
        if requestable.expired?
          case requestable.review_passed
          when true
            false
          when false
            true
          end
        end

      @form =
        QualificationRequestForm.new(
          requestable:,
          user: current_staff,
          received:,
          passed:,
          note: requestable.review_note,
          failed:,
        )
    end

    def update
      @form =
        QualificationRequestForm.new(
          form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :qualification_requests,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def edit_consent_method
      @form =
        ConsentMethodForm.new(
          qualification_request:,
          consent_method: qualification_request.consent_method,
        )
    end

    def update_consent_method
      @form =
        ConsentMethodForm.new(
          consent_method_form_params.merge(qualification_request:),
        )

      if @form.save
        if (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        elsif (
              next_qualification_request =
                qualification_requests[
                  qualification_requests.index(qualification_request) + 1
                ]
            )
          redirect_to [
                        :consent_method,
                        :assessor_interface,
                        application_form,
                        assessment,
                        next_qualification_request,
                      ]
        else
          redirect_to [
                        :check_consent_methods,
                        :assessor_interface,
                        application_form,
                        assessment,
                        :qualification_requests,
                      ]
        end
      else
        render :edit_consent_method, status: :unprocessable_entity
      end
    end

    def edit_request
      @form =
        RequestableRequestForm.new(
          requestable:,
          user: current_staff,
          passed: qualification_request.requested?,
        )
    end

    def update_request
      @form =
        RequestableRequestForm.new(
          requestable:,
          user: current_staff,
          passed:
            params.dig(:assessor_interface_requestable_request_form, :passed) ||
              false,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :qualification_requests,
                    ]
      else
        render :edit_request, status: :unprocessable_entity
      end
    end

    def edit_review
      @form = RequestableReviewForm.new(requestable:)
    end

    def update_review
      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          **requestable_review_form_params,
        )

      if @form.save
        redirect_to [:review, :assessor_interface, application_form, assessment]
      else
        render :edit_review, status: :unprocessable_entity
      end
    end

    private

    def application_form
      @application_form ||=
        ApplicationForm.includes(:assessment).find_by(
          reference: params[:application_form_reference],
          assessment: {
            id: params[:assessment_id],
          },
        )
    end

    def assessment
      @assessment ||= application_form.assessment
    end

    def qualification_requests
      @qualification_requests ||=
        assessment.qualification_requests.includes(:qualification).order_by_role
    end

    def qualification_request
      @qualification_request ||= qualification_requests.find(params[:id])
    end

    alias_method :requestable, :qualification_request

    def set_collection_variables
      authorize %i[assessor_interface qualification_request]

      @application_form = application_form
      @assessment = assessment
      @qualification_requests = qualification_requests
    end

    def set_member_variables
      @qualification_request =
        authorize [:assessor_interface, qualification_request]
      @application_form = qualification_request.application_form
      @assessment = qualification_request.assessment
    end

    def generate_unsigned_consent_document_form_params
      params.require(
        :assessor_interface_generate_unsigned_consent_document_form,
      ).permit(:generated)
    end

    def form_params
      params.require(:assessor_interface_qualification_request_form).permit(
        :received,
        :passed,
        :note,
        :failed,
      )
    end

    def consent_method_form_params
      params.require(:assessor_interface_consent_method_form).permit(
        :consent_method,
      )
    end

    def upload_unsigned_consent_document_form_params
      params.require(
        :assessor_interface_upload_unsigned_consent_document_form,
      ).permit(:original_attachment)
    end

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end
  end
end

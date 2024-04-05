# frozen_string_literal: true

module AssessorInterface
  class ConsentRequestsController < BaseController
    include HistoryTrackable

    before_action :set_collection_variables,
                  only: %i[new edit_request update_request]
    before_action :set_member_variables,
                  only: %i[
                    edit_upload
                    update_upload
                    check_upload
                    edit_verify
                    update_verify
                    edit_verify_failed
                    update_verify_failed
                    edit_review
                    update_review
                  ]

    skip_before_action :track_history, only: :new

    def new
      qualification =
        application_form.qualifications.find(params[:qualification_id])

      redirect_to [
                    :check_upload,
                    :assessor_interface,
                    application_form,
                    assessment,
                    consent_requests.find_or_create_by(qualification:),
                  ]
    end

    def edit_request
    end

    def update_request
      RequestConsent.call(assessment:, user: current_staff)

      redirect_to [
                    :assessor_interface,
                    application_form,
                    assessment,
                    :qualification_requests,
                  ]
    end

    def edit_upload
      @form = UploadUnsignedConsentDocumentForm.new(consent_request:)
    end

    def update_upload
      @form =
        UploadUnsignedConsentDocumentForm.new(
          consent_request:,
          original_attachment:
            params.dig(
              :assessor_interface_upload_unsigned_consent_document_form,
              :original_attachment,
            ),
        )

      if @form.save
        if (check_path = history_stack.last_path_if_check)
          redirect_to check_path
        else
          redirect_to [
                        :assessor_interface,
                        application_form,
                        assessment,
                        :qualification_requests,
                      ]
        end
      else
        render :edit_upload, status: :unprocessable_entity
      end
    end

    def check_upload
      unless consent_request.unsigned_consent_document.completed? &&
               consent_request.unsigned_consent_document.downloadable?
        history_stack.pop

        redirect_to [
                      :upload,
                      :assessor_interface,
                      application_form,
                      assessment,
                      consent_request,
                    ]
      end
    end

    def edit_verify
      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.verify_passed,
          received: requestable.received?,
        )
    end

    def update_verify
      passed =
        params.dig(:assessor_interface_requestable_verify_passed_form, :passed)

      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed:,
          received: requestable.received?,
        )

      if passed == "nil" || @form.save
        if @form.passed # nil is parsed as true
          redirect_to [
                        :assessor_interface,
                        application_form,
                        assessment,
                        :qualification_requests,
                      ]
        else
          redirect_to [
                        :verify_failed,
                        :assessor_interface,
                        application_form,
                        assessment,
                        consent_request,
                      ]
        end
      else
        render :edit_verify, status: :unprocessable_entity
      end
    end

    def edit_verify_failed
      @form =
        RequestableVerifyFailedForm.new(
          requestable:,
          user: current_staff,
          note: requestable.verify_note,
        )
    end

    def update_verify_failed
      @form =
        RequestableVerifyFailedForm.new(
          verify_failed_form_params.merge(requestable:, user: current_staff),
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      application_form,
                      assessment,
                      :qualification_requests,
                    ]
      else
        render :edit_verify_failed, status: :unprocessable_entity
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
          **review_form_params,
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

    def consent_requests
      @consent_requests ||= assessment.consent_requests
    end

    def consent_request
      @consent_request ||= consent_requests.find(params[:id])
    end

    alias_method :requestable, :consent_request

    def set_collection_variables
      authorize %i[assessor_interface consent_request]
      @consent_requests = consent_requests
      @application_form = application_form
      @assessment = assessment
    end

    def set_member_variables
      @consent_request = authorize [:assessor_interface, consent_request]
      @application_form = application_form
      @assessment = assessment
    end

    def verify_failed_form_params
      params.require(:assessor_interface_requestable_verify_failed_form).permit(
        :note,
      )
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end
  end
end

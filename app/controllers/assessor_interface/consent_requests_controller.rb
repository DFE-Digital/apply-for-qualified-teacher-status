# frozen_string_literal: true

module AssessorInterface
  class ConsentRequestsController < BaseController
    include HistoryTrackable

    before_action :set_variables, except: :new

    skip_before_action :track_history, only: :new

    def new
      authorize %i[assessor_interface consent_request]

      qualification =
        application_form.qualifications.find(params[:qualification_id])

      redirect_to [
                    :upload,
                    :assessor_interface,
                    application_form,
                    assessment,
                    consent_requests.find_or_create_by(qualification:),
                  ]
    end

    def edit_upload
      @form = UploadUnsignedConsentDocumentForm.new(consent_request:)
    end

    def update_upload
      @form =
        UploadUnsignedConsentDocumentForm.new(
          upload_unsigned_consent_document_form_params.merge(consent_request:),
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

    def set_variables
      @consent_request = authorize [:assessor_interface, consent_request]
      @application_form = application_form
      @assessment = assessment
    end

    def upload_unsigned_consent_document_form_params
      params.require(
        :assessor_interface_upload_unsigned_consent_document_form,
      ).permit(:original_attachment)
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    alias_method :requestable, :consent_request
  end
end

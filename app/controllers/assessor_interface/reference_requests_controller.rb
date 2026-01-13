# frozen_string_literal: true

module AssessorInterface
  class ReferenceRequestsController < BaseController
    before_action :set_individual_variables, except: :index

    def index
      authorize %i[assessor_interface reference_request]

      @reference_requests = reference_requests
      @application_form = reference_requests.first.application_form
      @assessment = reference_requests.first.assessment

      render layout: "full_from_desktop"
    end

    def edit_review
      @form =
        RequestableReviewForm.new(
          requestable:,
          passed: requestable.review_passed,
          note: requestable.review_note,
        )
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

    def edit_verify
      @view_object = ReferenceRequestViewObject.new(reference_request:)

      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.verify_passed,
          received: requestable.received?,
        )
    end

    def update_verify
      @view_object = ReferenceRequestViewObject.new(reference_request:)

      passed =
        params.dig(:assessor_interface_requestable_verify_passed_form, :passed)

      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed:,
          received: requestable.received?,
        )

      if @form.save
        if @form.passed
          redirect_to [
                        :assessor_interface,
                        application_form,
                        assessment,
                        :reference_requests,
                      ]
        else
          redirect_to [
                        :verify_failed,
                        :assessor_interface,
                        application_form,
                        assessment,
                        reference_request,
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
                      :reference_requests,
                    ]
      else
        render :edit_verify_failed, status: :unprocessable_entity
      end
    end

    def edit_resend_email
      @view_object = ReferenceRequestViewObject.new(reference_request:)
    end

    def update_resend_email
      reference_request.send_requested_email

      redirect_to [
                    :resend_email_confirmation,
                    :assessor_interface,
                    assessment.application_form,
                    assessment,
                    reference_request,
                  ]
    end

    def resend_email_confirmation
      @view_object = ReferenceRequestViewObject.new(reference_request:)
    end

    private

    def set_individual_variables
      @reference_request = authorize [:assessor_interface, reference_request]
      @application_form = reference_request.application_form
      @assessment = reference_request.assessment
    end

    def review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    def verify_failed_form_params
      params.require(:assessor_interface_requestable_verify_failed_form).permit(
        :note,
      )
    end

    def reference_requests
      @reference_requests ||=
        ReferenceRequest
          .joins(assessment: :application_form)
          .includes(:work_history)
          .where(
            assessment_id: params[:assessment_id],
            application_form: {
              reference: params[:application_form_reference],
            },
          )
          .order_by_role
    end

    def reference_request
      @reference_request ||= reference_requests.find(params[:id])
    end

    delegate :application_form, :assessment, to: :reference_request

    alias_method :requestable, :reference_request
  end
end

# frozen_string_literal: true

module AssessorInterface
  class ReferenceRequestsController < BaseController
    before_action :set_individual_variables, except: :index

    define_history_origin :index

    def index
      authorize %i[assessor_interface reference_request]

      @reference_requests = reference_requests
      @application_form = reference_requests.first.application_form
      @assessment = reference_requests.first.assessment

      render layout: "full_from_desktop"
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

    def edit_verify
      @form =
        RequestableVerifyPassedForm.new(
          requestable:,
          user: current_staff,
          passed: requestable.verify_passed,
        )
    end

    def update_verify
      @form =
        RequestableVerifyPassedForm.new(
          verify_passed_form_params.merge(requestable:, user: current_staff),
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
                      requestable.application_form,
                      requestable.assessment,
                      :reference_requests,
                    ]
      else
        render :edit_verify_failed, status: :unprocessable_entity
      end
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

    def verify_passed_form_params
      params.require(:assessor_interface_requestable_verify_passed_form).permit(
        :passed,
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

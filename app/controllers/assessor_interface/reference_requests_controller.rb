# frozen_string_literal: true

module AssessorInterface
  class ReferenceRequestsController < BaseController
    before_action :authorize_assessor, except: %i[edit update_verify_references]

    before_action :set_list_variables, only: %i[index update_verify_references]
    before_action :set_individual_variables, only: %i[edit update]

    def index
      @form =
        VerifyReferencesForm.new(
          assessment:,
          references_verified: assessment.references_verified,
        )

      render layout: "application"
    end

    def update_verify_references
      authorize :assessor, :update?

      @form =
        VerifyReferencesForm.new(assessment:, **verify_references_form_params)

      if @form.save
        redirect_to [:assessor_interface, @application_form]
      else
        render :index, layout: "application", status: :unprocessable_entity
      end
    end

    def edit
      authorize :assessor, :show?

      @form = RequestableReviewForm.new(requestable:)
    end

    def update
      @form =
        RequestableReviewForm.new(
          requestable:,
          user: current_staff,
          **requestable_review_form_params,
        )

      if @form.save
        redirect_to [
                      :assessor_interface,
                      requestable.application_form,
                      requestable.assessment,
                      :reference_requests,
                    ]
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_list_variables
      @reference_requests = reference_requests
      @application_form = reference_requests.first.application_form
      @assessment = assessment
    end

    def set_individual_variables
      @reference_request = reference_request
      @application_form = reference_request.application_form
      @assessment = reference_request.assessment
    end

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
        :note,
      )
    end

    def verify_references_form_params
      params.fetch(:assessor_interface_verify_references_form, {}).permit(
        :references_verified,
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
          .order("work_histories.start_date": :desc)
    end

    def reference_request
      @reference_request ||= reference_requests.find(params[:id])
    end

    def assessment
      @assessment ||= reference_requests.first.assessment
    end

    alias_method :requestable, :reference_request
  end
end

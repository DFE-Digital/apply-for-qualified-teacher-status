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

    def edit
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

    def set_individual_variables
      @reference_request = authorize [:assessor_interface, reference_request]
      @application_form = reference_request.application_form
      @assessment = reference_request.assessment
    end

    def requestable_review_form_params
      params.require(:assessor_interface_requestable_review_form).permit(
        :passed,
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

# frozen_string_literal: true

module AssessorInterface
  class AssessmentRecommendationVerifyController < BaseController
    before_action :authorize_assessor, only: %i[edit update]
    before_action :ensure_can_verify
    before_action :load_assessment_and_application_form

    def edit
      redirect_to [
                    :reference_requests,
                    :assessor_interface,
                    application_form,
                    assessment,
                    :assessment_recommendation_verify,
                  ]
    end

    def update
      ActiveRecord::Base.transaction do
        assessment.verify!
        CreateReferenceRequests.call(
          assessment:,
          user: current_staff,
          work_histories:
            WorkHistory.where(
              application_form:,
              id: session[:work_history_ids],
            ),
        )
      end

      redirect_to [:status, :assessor_interface, application_form]
    end

    def edit_reference_requests
      authorize :assessor, :edit?

      @form =
        WorkHistoryReferenceRequestForm.new(
          application_form:,
          session:,
          work_history_ids: application_form.work_histories.pluck(:id),
        )
    end

    def update_reference_requests
      authorize :assessor, :update?

      work_history_ids =
        params.dig(
          :assessor_interface_work_history_reference_request_form,
          :work_history_ids,
        ).compact_blank

      @form =
        WorkHistoryReferenceRequestForm.new(
          application_form:,
          session:,
          work_history_ids:,
        )

      if @form.save
        redirect_to [
                      :preview_referee,
                      :assessor_interface,
                      application_form,
                      assessment,
                      :assessment_recommendation_verify,
                    ]
      else
        render :edit_reference_requests, status: :unprocessable_entity
      end
    end

    def preview_referee
      authorize :assessor, :edit?
      @reference_requests = assessment.reference_requests
    end

    def preview_teacher
      authorize :assessor, :edit?
    end

    private

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:assessment_id])
    end

    delegate :application_form, to: :assessment

    def ensure_can_verify
      unless assessment.can_verify?
        redirect_to [:assessor_interface, application_form]
      end
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end
  end
end

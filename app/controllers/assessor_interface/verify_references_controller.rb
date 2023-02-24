# frozen_string_literal: true

module AssessorInterface
  class VerifyReferencesController < BaseController
    before_action :authorize_note

    def index
      @view_object = VerifyReferencesViewObject.new(assessment:)
      @form =
        VerifyReferencesForm.new(
          assessment:,
          references_verified: assessment.references_verified,
        )
    end

    def update
      @view_object = VerifyReferencesViewObject.new(assessment:)
      @form = VerifyReferencesForm.new(assessment:, **verify_references_params)

      if @form.save
        redirect_to [:assessor_interface, assessment.application_form]
      else
        render :index, status: :unprocessable_entity
      end
    end

    def assessment
      @assessment ||= Assessment.find(params[:assessment_id])
    end

    def verify_references_params
      params.fetch(:assessor_interface_verify_references_form, {}).permit(
        :references_verified,
      )
    end
  end
end

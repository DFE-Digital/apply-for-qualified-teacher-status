# frozen_string_literal: true

module AssessorInterface
  class AssessmentsController < BaseController
    before_action :load_assessment_and_application_form

    def edit
      authorize %i[assessor_interface assessment_recommendation]

      @form = AssessmentRecommendationForm.new(assessment:)
    end

    def update
      authorize %i[assessor_interface assessment_recommendation]

      @form =
        AssessmentRecommendationForm.new(
          assessment:,
          recommendation:
            params.dig(
              :assessor_interface_assessment_recommendation_form,
              :recommendation,
            ),
        )

      if @form.valid?
        redirect_to update_redirect_path(@form.recommendation)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def rollback
      authorize [:assessor_interface, assessment]
    end

    def destroy
      authorize [:assessor_interface, assessment]
      RollbackAssessment.call(assessment:, user: current_staff)
      redirect_to [:assessor_interface, application_form]
    rescue RollbackAssessment::InvalidState => e
      flash[:warning] = e.message
      render :rollback, status: :unprocessable_entity
    end

    private

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = application_form
    end

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:id])
    end

    delegate :application_form, to: :assessment

    def update_redirect_path(recommendation)
      if recommendation == "request_further_information"
        [
          :preview,
          :assessor_interface,
          application_form,
          assessment,
          :further_information_requests,
        ]
      else
        [
          :edit,
          :assessor_interface,
          application_form,
          assessment,
          :"assessment_recommendation_#{recommendation}",
        ]
      end
    end
  end
end

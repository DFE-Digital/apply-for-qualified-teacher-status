# frozen_string_literal: true

module AssessorInterface
  class AssessmentsController < BaseController
    before_action :authorize_assessor, except: %i[declare preview confirm]
    before_action :authorize_assessor_update, only: %i[declare preview confirm]
    before_action :load_assessment_and_application_form

    def edit
      @assessment_recommendation_form =
        AssessmentRecommendationForm.new(
          assessment:,
          user: current_staff,
          recommendation: assessment.recommendation,
        )
    end

    def declare
      @assessment_recommendation_form =
        AssessmentRecommendationForm.new(
          assessment_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @assessment_recommendation_form.needs_declaration?
        render :declare
      elsif @assessment_recommendation_form.save
        redirect_to post_update_redirect_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def preview
      @assessment_recommendation_form =
        AssessmentRecommendationForm.new(
          assessment_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @assessment_recommendation_form.needs_preview?
        render :preview
      elsif @assessment_recommendation_form.needs_confirmation?
        render :confirm
      elsif @assessment_recommendation_form.save
        redirect_to post_update_redirect_path
      else
        render :declare, status: :unprocessable_entity
      end
    end

    def confirm
      @assessment_recommendation_form =
        AssessmentRecommendationForm.new(
          assessment_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @assessment_recommendation_form.needs_confirmation?
        render :confirm
      elsif @assessment_recommendation_form.save
        redirect_to post_update_redirect_path
      else
        render :declare, status: :unprocessable_entity
      end
    end

    def update
      @assessment_recommendation_form =
        AssessmentRecommendationForm.new(
          assessment_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @assessment_recommendation_form.save
        redirect_to post_update_redirect_path
      elsif @assessment_recommendation_form.needs_confirmation?
        render :confirm, status: :unprocessable_entity
      elsif @assessment_recommendation_form.needs_preview?
        render :preview, status: :unprocessable_entity
      elsif @assessment_recommendation_form.needs_declaration?
        render :declare, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def authorize_assessor_update
      authorize :assessor, :update?
    end

    def load_assessment_and_application_form
      @assessment = assessment
      @application_form = assessment.application_form
    end

    def assessment
      @assessment ||=
        Assessment
          .includes(:application_form)
          .where(application_form_id: params[:application_form_id])
          .find(params[:id])
    end

    def assessment_recommendation_form_params
      params.require(:assessor_interface_assessment_recommendation_form).permit(
        :recommendation,
        :declaration,
        :confirmation,
      )
    end

    def post_update_redirect_path
      if @assessment.request_further_information?
        [
          :preview,
          :assessor_interface,
          @application_form,
          @assessment,
          :further_information_requests,
        ]
      else
        [:status, :assessor_interface, @application_form]
      end
    end
  end
end

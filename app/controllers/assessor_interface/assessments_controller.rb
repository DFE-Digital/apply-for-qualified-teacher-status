module AssessorInterface
  class AssessmentsController < BaseController
    before_action :load_assessment_and_application_form

    def edit
      @confirm_recommendation_form =
        ConfirmRecommendationForm.new(
          assessment:,
          user: current_staff,
          recommendation: assessment.recommendation,
        )
    end

    def confirm
      @confirm_recommendation_form =
        ConfirmRecommendationForm.new(
          confirm_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @confirm_recommendation_form.needs_confirmation?
        render :confirm
      elsif @confirm_recommendation_form.save
        redirect_to post_update_redirect_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def update
      @confirm_recommendation_form =
        ConfirmRecommendationForm.new(
          confirm_recommendation_form_params.merge(
            assessment:,
            user: current_staff,
          ),
        )

      if @confirm_recommendation_form.save
        redirect_to post_update_redirect_path
      else
        render :confirm, status: :unprocessable_entity
      end
    end

    private

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

    def confirm_recommendation_form_params
      params.require(:assessor_interface_confirm_recommendation_form).permit(
        :recommendation,
        :confirm,
      )
    end

    def post_update_redirect_path
      if @assessment.request_further_information?
        return [
          :preview,
          :assessor_interface,
          @application_form,
          @assessment,
          :further_information_requests
        ]
      end

      [:assessor_interface, @application_form]
    end
  end
end

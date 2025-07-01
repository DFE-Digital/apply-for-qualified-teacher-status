# frozen_string_literal: true

module AssessorInterface
  class AssessmentsController < BaseController
    before_action :load_assessment_and_application_form

    before_action only: %i[edit update] do
      authorize %i[assessor_interface assessment_recommendation]
    end

    before_action except: %i[edit update] do
      authorize [:assessor_interface, assessment]
    end

    before_action :ensure_can_make_prioritisation_decision,
                  only: %i[edit_prioritisation update_prioritisation]

    def review
      @professional_standing_request =
        assessment.professional_standing_request if assessment.professional_standing_request&.verify_failed?

      @consent_requests =
        assessment
          .consent_requests
          .includes(:qualification)
          .where(verify_passed: false)
          .order_by_role

      @qualification_requests =
        assessment
          .qualification_requests
          .includes(:qualification)
          .where(verify_passed: false)
          .order_by_role

      @reference_requests =
        assessment
          .reference_requests
          .includes(:work_history)
          .where(verify_passed: false)
          .order_by_role

      render layout: "full_from_desktop"
    end

    def edit
      @form = AssessmentRecommendationForm.new(assessment:)
    end

    def update
      @form =
        AssessmentRecommendationForm.new(
          assessment:,
          confirmation:
            params.dig(
              :assessor_interface_assessment_recommendation_form,
              :confirmation,
            ),
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
    end

    def edit_prioritisation
      @form = AssessmentPrioritisationDecisionForm.new(assessment:)
    end

    def update_prioritisation
      @form =
        AssessmentPrioritisationDecisionForm.new(
          assessment:,
          user: current_staff,
          passed:
            params.dig(
              :assessor_interface_assessment_prioritisation_decision_form,
              :passed,
            ),
        )

      if @form.save
        redirect_to [
                      :confirm_prioritisation,
                      :assessor_interface,
                      application_form,
                      assessment,
                    ]
      else
        render :edit_prioritisation, status: :unprocessable_entity
      end
    end

    def confirm_prioritisation
    end

    def destroy
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
          .where(
            application_form: {
              reference: params[:application_form_reference],
            },
          )
          .find(params[:id])
    end

    delegate :application_form, to: :assessment

    def update_redirect_path(recommendation)
      if recommendation == "request_further_information"
        [
          :new,
          :assessor_interface,
          application_form,
          assessment,
          :further_information_request,
        ]
      else
        [
          :assessor_interface,
          application_form,
          assessment,
          :"assessment_recommendation_#{recommendation}",
        ]
      end
    end

    def ensure_can_make_prioritisation_decision
      return if @assessment.can_update_prioritisation_decision?

      redirect_to [:assessor_interface, application_form]
    end
  end
end
